## Design Review
### 问题 1

> [!question]
> 请分别展示发送和接收 DMA 描述符的示例，并介绍所填充字段的含义

#### 1. 发送描述符 (Transmit Descriptor) - (Slides 8-10)

**结构体示例 (C语言伪代码):**
```c
struct e1000_tx_desc {
    uint64_t addr;   // Buffer Address
    uint16_t length; // Length
    uint8_t cso;     // Checksum Offset
    uint8_t cmd;     // Command Field
    uint8_t status;  // Status Field
    uint8_t css;     // Checksum Start
    uint16_t special;
};
```

**填充字段含义及设置：**
*   **addr (Buffer Address):**
    *   **含义：** 数据缓冲区的**物理地址**。
    *   **设置：** 这里不能填虚拟地址，必须通过 `kvmpa` 或类似的宏将内核虚拟地址转换为物理地址填入。
*   **length:**
    *   **含义：** 要发送的数据包的长度（字节数）。
*   **cmd (Command):**
    *   **含义：** 控制 DMA 行为的命令字段。
    *   **设置 (参考 Slide 9):**
        *   `E1000_TXD_CMD_EOP` (End of Packet): 设置为 1，表示这是当前包的最后一个描述符。
        *   `E1000_TXD_CMD_RS` (Report Status): 设置为 1，告诉网卡处理完这个描述符后，在 `status` 字段报告状态（即设置 DD 位）。
        *   `E1000_TXD_CMD_DEXT` (Descriptor Extension): 设置为 0，表示使用 Legacy 格式。
*   **status:**
    *   **含义：** 存储网卡返回的状态。
    *   **检查 (参考 Slide 10):** OS 通过检查 `status` 中的 `DD` (Descriptor Done) 位来判断数据是否发送完成。初始化时该字段应为 0。

---

#### 2. 接收描述符 (Receive Descriptor) - (Slides 14-15)

**结构体示例:**
```c
struct e1000_rx_desc {
    uint64_t addr;      // Buffer Address
    uint16_t length;    // Length
    uint16_t checksum;  // Packet Checksum
    uint8_t status;     // Status Field
    uint8_t errors;     // Errors Field
    uint16_t special;
};
```

**填充字段含义及设置：**
*   **addr (Buffer Address):**
    *   **含义：** 用于接收数据的缓冲区的**物理地址**。
    *   **设置：** 同样必须是物理地址。OS 预先分配好内存，将地址填入，网卡收到数据后会写入这个地址。
*   **status:**
    *   **含义：** 接收状态。
    *   **检查 (参考 Slide 15):**
        *   `E1000_RXD_STAT_DD` (Descriptor Done): 当网卡把接收到的数据写入内存后，会将此位置 1。OS 轮询或在中断中检查此位来确定是否有新数据包到达。
        *   `E1000_RXD_STAT_EOP` (End of Packet): 表示数据包结束。
*   **length:**
    *   **含义：** 网卡实际写入缓冲区的数据长度。网卡在回写描述符时会更新此字段。

---

### 问题 2

> [!question]
> 请介绍网卡中断的处理流程，包含使用哪些寄存器、如何使能、判断和处理中断

这个部分需要结合 RISC-V 的 PLIC 和 E1000 内部的中断寄存器来回答。

#### 1. 如何使能中断 (Enabling Interrupts)

*   **E1000 侧 (参考 Slide 22):**
    *   **IMS (Interrupt Mask Set) 寄存器:** 向该寄存器的特定位写 1 来使能特定类型的网卡中断。
    *   **设置：** 需要使能 `TXQE` (Transmit Queue Empty，或类似发送完成中断) 和 `RXDMT0` (Receive Descriptor Minimum Threshold，接收数据中断)。
    *   代码示例：`e1000_write_reg(E1000_IMS, E1000_IMS_TXQE | E1000_IMS_RXDMT0);`
*   **RISC-V PLIC 侧:**
    *   需要设置 PLIC 的 Priority 寄存器（设置网卡中断优先级）。
    *   需要设置 PLIC 的 Enable 寄存器（使能 E1000 对应的 IRQ Number，QEMU通常是 33，板子是 3）。
*   **CPU 侧:**
    *   设置 `sstatus.SIE` 位，开启内核态全局中断。
    *   设置 `sie.SEIE` 位，开启外部中断。

#### 2. 如何判断中断 (Judging Interrupts)

当 CPU 跳转到中断处理函数 (`trap_handler`) 时：

1.  **检查 scause 寄存器 (参考 Slide 20):**
    *   判断最高位是否为 1（Interrupt），且低位是否对应 Supervisor External Interrupt (IRQ_S_EXT)。
2.  **查询 PLIC Claim 寄存器:**
    *   读取 PLIC Claim 寄存器获取中断源的 Device ID。
    *   如果 ID == 33 (QEMU) 或 3 (Board)，说明是网卡产生的中断。
3.  **查询 ICR (Interrupt Cause Read) 寄存器 (参考 Slide 23):**
    *   读取 E1000 的 `ICR` 寄存器。这个操作有两个作用：
        *   **获取具体原因：** 返回值的每一位代表不同的中断原因（如发送完成、接收到数据等）。
        *   **清除中断：** 读取 `ICR` 会自动清除 E1000 内部的中断状态（Write-to-Clear 或 Read-to-Clear）。

#### 3. 如何处理中断 (Processing Interrupts)

根据读取到的 `ICR` 的值进行分支处理：

*   **如果是发送中断 (ICR & E1000_ICR_TXQE) (参考 Slide 24):**
    *   这意味着发送队列有空闲了（或发送完成了）。
    *   **操作：** 唤醒因发送缓冲区满而阻塞的发送线程 (Task 3 要求)。如果有待发送的数据队列，可以继续触发发送。
*   **如果是接收中断 (ICR & E1000_ICR_RXDMT0/RXT0):**
    *   这意味着有数据包到达，或者接收描述符即将耗尽。
    *   **操作：** 唤醒被阻塞的接收线程。接收线程被唤醒后，会遍历接收描述符环形缓冲区，检查 `DD` 位，将数据取出并传递给上层协议栈（Syscall `sys_net_recv`）。

#### 4. 中断结束 (Completion)

*   **PLIC Complete:** 处理完逻辑后，必须将刚才从 Claim 拿到的 Device ID 写回 PLIC 的 Complete 寄存器，通知 PLIC 该中断已处理完毕，允许处理下一个同优先级中断。

---

### 问题 3：任何想讨论的问题 (Optional / Potential Discussion)

1.  **物理地址与虚拟地址的转换：**
    *   E1000 DMA 直接访问物理内存，而 OS 运行在虚拟内存上。讨论 `bios_read_fdt` 获取的是物理基址，需要 `ioremap` 映射到内核虚拟地址才能通过 CPU 读写寄存器；而填入 Descriptor 的地址必须是 `kvmpa` 转换后的物理地址。
2.  **Ring Buffer 的头尾指针管理：**
    *   发送：软件更新 `TDT` (Tail)，硬件更新 `TDH` (Head)。
    *   接收：软件更新 `RDT` (Tail)，硬件更新 `RDH` (Head)。
    *   **注意点：** 接收队列的 `RDT` 通常指向最后一个**可用**描述符的下一个位置的再前一个（或者说 `RDT` 指向的是最后一个由软件处理完并交还给硬件的描述符），这里容易出现 Off-by-one 错误。
3.  **Cache Coherence (缓存一致性)：**
    *   虽然在 QEMU 环境下可能不明显，但在真实硬件上，CPU 写入 Descriptor 后，数据可能还在 Cache 中。DMA 读取的是主存。理论上需要 `fence` 指令或 Cache Flush 操作来保证一致性（Slide 5 提到了 flush TLB，但 DMA 一致性通常涉及 Cache）。

---

## Fence

对于 fence 的理解：

`fence pred, succ`：保证 `pred` 的指令在 `succ` 前 _生效_

`pred, succ ` $\in$ $\{ \text{i},\text{o},\text{r},\text{w} \}$ （取指，IO输出，读内存，写内存）

_之前生效_：如果 A 在 B 前生效，且 C 在 D 前生效，那么不存在一种执行序列，使得 $C$ 执行时 $B$ 执行了，且 $D$ 执行时 $A$ 还没有执行。

```
#define RISCV_FENCE(p, s) \
        __asm__ __volatile__ ("fence " #p "," #s : : : "memory")

/* These barriers need to enforce ordering on both devices or memory. */
#define mb()            RISCV_FENCE(iorw,iorw)
#define rmb()           RISCV_FENCE(ir,ir)
#define wmb()           RISCV_FENCE(ow,ow)
```

考虑 producer-consumer 的场景：

```c
// init
p->data = 0;

...
// producer
p->data = 100;
wmb();
ready = 1;

...
// consumer
if (ready) {
	rmb();
	operation(p->data);
}
```

这里的 `rmb(), wmb()` 保证了 ready 时 data 一定有效（注意 `rmb()` 是必须的，因为考虑上面的定义，仅仅写的barrier 不能保证读的时候也是有序的）


### Fence和Cache

fence 是处理 cpu 内部的执行顺序问题，不保证数据 flush 到 ram 上对 DMA 设备可见，所以需要 `flush_dcache` 维持 DMA 收发时与 CPU 数据一致性。

---

## 描述符

![[Pasted image 20251220211823.png]]

![[Pasted image 20251220211928.png]]

处理环形缓冲区的满/空二义性问题？

硬件规定 `head == tail` 时的语义是缓冲区为空

---

## 内存布局

内核太大了，更新bootblock传参地址，否则会被内核覆盖

| Name                        | Address                                            |
| --------------------------- | -------------------------------------------------- |
| Segment0 BBL代码及内存           | `0xffffffc0_50000000 - 0xffffffc0_50200000`        |
| Segment1 Kernel 的数据段/代码段    | `0xffffffc0_50200000 - 0xffffffc0_51000000`        |
| Segment2 Kernel 页表以及跳转表等    | `0xffffffc0_51000000 - 0xffffffc0_52000000`        |
| Segment3 供内核动态分配使用的内核虚拟地址空间 | `0xffffffc0_52000000 - 0xffffffc0_60000000`        |
| bootloader 入口               | `0x50200000` $\in\text{PhysicalSeg1}$              |
| PGDIR_PA                    | `0x51000000` $\in\text{PhysicalSeg2}$              |
| bootblock taskinfo 地址       | `0x55000000` $\in\text{PhysicalSeg3}$              |
| bootblock argv 地址           | `0x56000000` $\in\text{PhysicalSeg3}$              |
| hart#0 `boot_kernel()` 栈空间  | `0x50fff000 - 0x51000000` $\in\text{Seg}1$         |
| hart#1 `boot_kernel()` 栈空间  | `0x50ffe000 - 0x50fff000` $\in\text{Seg}3$         |
| hart#0 `init/main()` 栈空间    | `0xf*c052000000 - 0xf*c052001000` $\in\text{Seg}3$ |
| hart#1 ` init/main()` 栈空间   | `0xf*c052001000 - 0xf*c052002000` $\in\text{Seg}3$ |
| `init/main()` 入口            | `0xf*c0_50202000` $\in\text{Seg1}$                 |
| kernel jmptab               | `0xf*c0_51ffff00` $\in\text{Seg}2$                 |


---

## BUG

奇怪的bug：为什么会有0x80中断？只开了txqe和rxdmt0啊

```
[WARN]  0|./drivers/e1000.c:234 (e1000_handle_interrupt)        unknown e1000 interrupt, icr=80
```

奇怪的上板问题：不开log时会在一个mini_strlen里面爆load page fault，一旦打开log，问题就消失了，但可以看到一直有interrupt，是来自e1000的txqe，修复了这个txqe的问题之后原来的load pagefault也消失了