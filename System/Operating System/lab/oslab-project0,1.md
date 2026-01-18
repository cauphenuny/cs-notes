---
title: "OS Lab: project0"
date: 2025-09-27 17:40:24
categories:
  - CS
  - labs
  - os
tags:
---
## Makefile 分析

```
# -----------------------------------------------------------------------
# Build and Debug Tools
# -----------------------------------------------------------------------

CROSS_PREFIX    = riscv64-unknown-linux-gnu-
CC                              = $(CROSS_PREFIX)gcc
GDB                             = $(CROSS_PREFIX)gdb
QEMU                    = $(DIR_QEMU)/riscv64-softmmu/qemu-system-riscv64

# -----------------------------------------------------------------------
# Build/Debug Flags and Variables
# -----------------------------------------------------------------------

CFLAGS                  = -O0 -fno-builtin -nostdlib -nostdinc -Wall -mcmodel=medany -ggdb3
USER_CFLAGS             = $(CFLAGS) -Wl,--defsym=TEXT_START=$(USER_ENTRYPOINT) -T riscv.lds

QEMU_OPTS               = -nographic -machine virt -m 256M -kernel $(ELF_USER) -bios none
QEMU_DEBUG_OPT  = -s -S

# -----------------------------------------------------------------------
# UCAS-OS Entrypoints and Variables
# -----------------------------------------------------------------------

USER_ENTRYPOINT                 = 0x50000000
```

- `CFLAGS`：编译器选项。  
  - `-O0`：无优化，便于调试。
  - `-fno-builtin`：禁用内建函数，适合裸机开发。
  - `-nostdlib -nostdinc`：不使用标准库和头文件，适合操作系统或裸机环境。
  - `-Wall`：开启所有警告。
  - `-mcmodel=medany`：RISC-V 地址模型，支持任意地址访问。
  - `-ggdb3`：生成详细的调试信息。

- `USER_CFLAGS`：用户程序编译选项。  
  - 包含 `CFLAGS`。
  - `-Wl,--defsym=TEXT_START=$(USER_ENTRYPOINT)`：链接器选项，定义程序入口地址为 `USER_ENTRYPOINT`。
  - `-T riscv.lds`：指定链接脚本。

- `QEMU_OPTS`：QEMU 启动参数。  
  - `-nographic`：无图形界面，使用终端。
  - `-machine virt -m 256M`：虚拟机类型和内存大小。
  - `-kernel $(ELF_USER)`：加载编译好的用户程序。
  - `-bios none`：不加载 BIOS。

- `QEMU_DEBUG_OPT`：QEMU 调试参数。  
  - `-s`：开启 GDB 远程调试端口（默认 1234）。
  - `-S`：启动后暂停 CPU，等待调试器连接。

- `USER_ENTRYPOINT`：用户程序入口地址，裸机程序从此地址开始执行（0x50000000）。

> [!info] RISC-V 地址模型
> - **medany**（medium any）：  
  支持代码和数据位于任意 2GB 地址空间，适合嵌入式或操作系统开发。代码通过 PC-relative addressing 访问数据和函数，允许程序运行在高地址（如 0x50000000），不受低地址限制。
> - **medlow**：  
  代码和数据都必须在低 2GB 地址空间（0x0 ~ 0x7FFFFFFF），适合普通应用程序，访问更高地址会出错。

---

## 小型测试

```c
.global main

msg: .string "Hello, World!\n"
len = . - msg

main:
    add x1, x0, 1
```

启动：
qemu virt机器启动地址：`0x1000`

```c
(lldb) dis -s 0x1000 -e 0x1018
    0x1000: auipc  t0, 0x0
    0x1004: addi   a2, t0, 0x28
    0x1008: csrr   a0, mhartid
    0x100c: ld     a1, 0x20(t0)
    0x1010: ld     t0, 0x18(t0)
    0x1014: jr     t0
```

将 PC (`0x1000`) 放到 t0，a2放 PC+0x28 (`0x1028`)，将当前hart id读到 a0，加载`0x1020` 处数据到 a1，加载 `0x1018` 处数据到 t0，跳转到 t0

`0x1018` 附近数据：

```c
(lldb) memory read -fx -s4 -c4 0x1018
0x00001018: 0x50000000 0x00000000 0x5fe00000 0x00000000
```

可以看到，`0x1018` 存的正是前面makefile中设置的 elf 入口点

此时寄存器状态：
```c
(lldb) reg read t0 a0 a1 a2
      t0 = 0x0000000050000000  main`_ftext
      a0 = 0x0000000000000000
      a1 = 0x000000005fe00000
      a2 = 0x0000000000001028
```

有个问题：为什么 `readelf` 显示的是 `0x5000000f`? 这地址甚至都没有 2 字节对齐

```
$ readelf -h main
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           RISC-V
  Version:                           0x1
  Entry point address:               0x5000000f
  Start of program headers:          64 (bytes into file)
  Start of section headers:          5448 (bytes into file)
  Flags:                             0x5, RVC, double-float ABI
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         2
  Size of section headers:           64 (bytes)
  Number of section headers:         12
  Section header string table index: 11
```

`0x5000000f` 确实是main的位置，而 `0x50000000` 是 `_ftext`

```c
(lldb) dis -s 0x5000000f
main`main:
    0x5000000f <+0>: li     ra, 0x1

(lldb) image lookup -n _ftext
1 match found in os-lab/source/main:
        Address: main[0x0000000050000000] (main.PT_LOAD[0]..text + 0)
        Summary: main`_ftext
```

这一段 `_ftext` 只有 5 条指令

```c
(lldb) dis
main`_ftext:
->  0x50000000 <+0>:  ld     a0, 0x88(a0)
    0x50000002 <+2>:  ld     a1, 0xd8(s0)
    0x50000004 <+4>:  jal    s8, 0x50002576
    0x50000008 <+8>:  jal    tp, 0x500c764e
    0x5000000c <+12>: addi   s4, s4, 0x8
```

这些指令看起来非常奇怪

```
(lldb) mem read -fc -s1 -c32 0x50000000
0x50000000: Hello, World!\n\0\x93\0\x10\0\0\0\0\0\0\0\0\0\0\0\0\0\0
```

搞错了，msg应该放 `.data` section 的（难怪没对齐）（好蠢的错误

删除所有无关代码

```
.global main

main:
    add x1, x0, 1
```

entrance 正常了

```
 readelf -h main
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           RISC-V
  Version:                           0x1
  Entry point address:               0x50000000
  Start of program headers:          64 (bytes into file)
  Start of section headers:          5328 (bytes into file)
  Flags:                             0x5, RVC, double-float ABI
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         2
  Size of section headers:           64 (bytes)
  Number of section headers:         12
  Section header string table index: 11
```

---

## Task0:

> [!assignment] Task0
> 1到50的叠加，叠加的结果放到指定的内存地址上（实现时使用常量宏存这个地址，通过la指令把叠加结果写到这个地址上）


```
.global main

main:
    li t1, 1      # i = 1
    li t2, 0      # sum = 0
    li t3, 50
    j start

start:
    bgt t1, t3, end   # if i > 50: goto end
    add t2, t2, t1    # sum += i
    addi t1, t1, 1    # i += 1
    j start           # goto start

end:
    la t3, retval_addr
    sw t2, 0(t3)
    j halt

halt:
    nop
    j halt

.section data
.equ retval_addr, 0x50001000
```

累加 0-50。

似乎 `0x60000000` 区域地址不可写，为常量 `0xffffffff`，`0x50001000` 区域是正常的

超过 RAM 大小了？256M=`0x10000000`，测试一下 `0x5ffffffc`

`0x5ffffffc` 可写，所以RAM加载的地址范围是 `[0x50000000, 0x60000000)`

---

## Task1

> [!assignment] Task1
> 判断1到200的每个数字是否为质数，要求用函数调用实现，函数参数为数字，返回值为是否是质数。

发现一个问题：一定要把main放在文件开头，不然main代码不会放到 `0x50000000`?

```
(lldb) b *0x50000000
Breakpoint 1: where = task1`_ftext, address = 0x0000000050000000
(lldb) b halt
Breakpoint 2: where = task1`halt + 2, address = 0x0000000050000024
(lldb) c
Process 1 resuming
Process 1 stopped
* thread #1, stop reason = breakpoint 1.1
    frame #0: 0x0000000050000000 task1`_ftext at task1.S:7
   4    /*
   5     *  (n: a0:int) -> is_prime: a0:int
   6     */
-> 7        li t0, 1          # is_prime = 1
   8        li t1, 2          # i = 2
   9        mv t2, a0         # n = a0
   10   loop_cond:
(lldb) image lookup -n main
1 match found in /Users/task1/Source/Courses/os-lab/source/task1:
        Address: task1[0x000000005000001c] (task1.PT_LOAD[0]..text + 28)
        Summary: task1`main
(lldb) 
```

---

## Task2

根据链接脚本，bss 段起止：\[ `__bss_start` , `__BSS_END__` ) 

---

## Task3

记得在 `crt0.S` 里面存好 `ra` 用来返回 kernel

task_num 怎么传递给 kernel 呢？目前用的是第一个扇区最后两个字节，然后在加载内核的时候传递给 kernel 的第一个参数


---

## Task4

uboot: `0x5000_0000`
bootblock: `0x5020_0000`
kernel: `0x5020_1000`
kernel_stack_top: `0x5050_0000`
taskinfo: `0x5060_0000`
kernel_jump_table: `0x51ff_ff00`

apps: `0x5200_0000`, `0x5201_0000` ...

**kernel_args: `0x50700000`**
user_stack_top: `0x5f00_0000`
\*reserved for temp data: `0x5f00_0000`: `0x6000_0000`

---

## Task5

存放task_info的地方：单独有一个扇区，方便bootblock读取，将扇区index存在扇区0的固定地方

类似地，将存batch_file的sector index 也存在一个固定的地方

将task_info等信息位置在bootblock中构造到kernel_args的地方传给kernel

---


kernel_arguments: `0x5070_0000`
\*batch pipeline data: `0x5ffffff0`

bootblock 向 kernel.main 传参的时候不能用把参数放 sp 上，因为 sp 这时候还没有初始化为 kernel_stack，还是u-boot里面的值，在这里写会破坏u-boot的栈

`qemu` $\to$ `u-boot` $\to$ `bootblock::main` $\to$ `head.S::_start` $\to$ `main.c::main`

$\to$ `crt0.S::_start` $\to$ `user_program::main`

---

在 `crt0` 里面，除了存下 `ra`，还要存 `sp`，不能直接设置 `la sp, USER_STACK_TOP`，不然 sp 的值会被 user_stack 覆盖

```
(gdb) x/10i $pc-4
   0x5020164c <run_task+124>:   ld      s2,32(sp)
   0x5020164e <run_task+126>:   ld      ra,56(sp)
=> 0x50201650 <run_task+128>:   li      a4,0
   0x50201652 <run_task+130>:   li      a3,0
   0x50201654 <run_task+132>:   li      a2,0
   0x50201656 <run_task+134>:   li      a1,0
   0x50201658 <run_task+136>:   auipc   a0,0x0
   0x5020165c <run_task+140>:   addi    a0,a0,784
   0x50201660 <run_task+144>:   addi    sp,sp,64
   0x50201662 <run_task+146>:   jr      a5
(gdb) p/x $sp
$1 = 0x5f000000
(gdb) 
```

---

需要设置一下 jmptab 的 `SD_WRITE` 项

---
