
## Task 7

instrument group:
```
add.w | sub.w | and | or | nor | xor | slt | sltu
addi.w | addi.w | slli.w | srli.w | srai.w
ld.w | st.w
bne | beq | b | bl | jirl
```

instrument that need mem-write:
`st.w` : from ID stage.

instruments that need reg-write:
`add.w`, `sub.w`,`and`,`or`,`nor`,`xor`,`slt`,`sltu`,`addi.w`,`slli.w`,`srli.w`,`srai.w`: from EX stage.
`jirl`: $\text{PC}+4$ (to `rd`) (also from EX)
`bl`: $\text{PC}+4$ (to `r1`) (also from EX)
`ld.w`: from MEM stage.

---

- bug on 2097 ns: 

```
1c000000 <_start>:
kernel_entry():
1c000000:	02bffc0c 	addi.w	$r12,$r0,-1(0xfff)
1c000004:	02bffc0c 	addi.w	$r12,$r0,-1(0xfff)
1c000008:	50fff800 	b	65528(0xfff8) # 1c010000 <locate>
```

IF 模块取出的指令是：
```
00000: 02bfffc0c
00004: 02bfffc0c
00008: 02bfffc0c
```

分析一下，现在的逻辑是：

```
cycle0:
	input_pc => pc
	inst_addr = input_pc
	inst_data = N/A
	inst_data => inst

cycle1:
	output_pc = pc	
	output_inst = inst
```

其实还是相当于异步ram了，同步ram的话应该把 inst_addr 输出放在 IF 级之前

```
cycle0:
	next_pc = br_taken ? br_target : (preIF.pc + 4)
	inst_addr = next_pc
	next_pc => preIF.pc
cycle1:
	preIF.pc => IF.pc
	inst_data => IF.inst // get inst data after one cycle
cycle2:
	IF.output_pc = IF.pc
	IF.output_inst = IF.inst
```

> [!warning]
> 这样的话 IF 流水级本身不保存指令地址，要求 ram 在没有新请求之前保持原来的值，否则流水线阻塞的时候会不会有问题
> 解决方案：加一级真正的 pre-IF流水级？

```
cycle0:
	next_pc => preIF.pc
cycle1:
	inst_addr = preIF.pc
cycle2:
	preIF.pc => IF.pc
	inst_data => IF.inst
```

这样可以保证 preIF-IF 握手成功时的 inst_data 和 传入的 pc 一定是匹配的

更新：本身 cpu top 里面就有一个pc reg，只需要握手成功时更改 pc 就行了，同时把指令 req 从 next_pc 改成当前pc

```
cycle ...0:
	next_pc =?> cpu.pc // transfer when if_allowin and if_validin
	inst_addr = cpu.pc
cycle 1:
	cpu.pc => IF.pc // transfer when if_allowin and if_validin
	inst_data => IF.pc
```

这样会导致一个问题：如果 br_taken 为 1，当前 pc reg 中的指令其实是无效的，怎么解决呢？
- 设置 if_validin 为 0，但这样会影响握手逻辑，可能会无法在当前 `br_taken = 1, br_target` 有效的周期内设置完 cpu.pc，因为在 `if_validin == 0, if_allowin == 1` 的状态，pc 无法更新。
- 握手信号不变，将传入 IF 的 validin 信号从 `if_validin` 变成 `if_validin & ~br_taken`，可以在握手成功，TOP module这边 flush 信号的同时 invalid 掉当前 pc reg 的指令。
- 似乎还是不能保证在产生 `br_taken` 和 `br_target` 信号的当前周期就把 cpu.pc 刷新（如果 IF 阻塞，ID指令流出之后 `valid` 等于 0，而`br_taken=1` 又要求 `valid=1` ）
	- IF 不可能阻塞，whatever。碰到问题再说，相信后人智慧

其实感觉想这么多，有点高耦合了，就应该像计组cpu一样，top 和 if 握手成功送一个 pc 进去，内部这个 pc 对应的是怎么搞由内部决定，无论是状态机还是流水线

---

- bug on 35977 ns

类似的问题，应该让mem请求在ex级发出
保留 ex 向 mem 的 mem_read 信号（需要作为 mem_data / alu_result 二选一依据）。

---

## Task8

通过 inst en 片选信号控制读入请求，实现阻塞时指令输出不变

ID stall 时 br_taken 不能为1

![[calab-task8.png]]

---

## Task9

前递时得考虑寄存器是否是 0 号，如果是 0 号不能递出数据

```
ld.w x0, ...
add.w x1, x0, x2 # 不能用内存读出数据作为 x0
```

---
前递路径选择：
1. 前递到寄存器读出
2. 前递到alu操作数

假设 两条指令 $A$ 和 $B$ 数据相关，$B$ 指令需要拿到 $A$ 指令的计算结果
能读出前递数据的前提条件是 $A$ 指令仍然在流水线中，没有流出，所以当 $A$-$B$ 之间差3拍时，若选择第二种方案，则 $A$ 指令在取寄存器值的同时 $B$ 在写寄存器，而 $A$ 在执行级的时候 $B$ 已经流出了，无法前递。

同时，转移指令也需要前递到 ID 级，综上，选择方案一。

选择方案一，将 执行级ALU结果输出、RAM返回数据二选一结果输出、访存写入数据输出 前递到 寄存器读出值处（以上三个起点分别对应差1,2,3拍的情况）

---
前递时，需要注意优先级，距离越近优先级越高

![[calab-task9.png]]

![[calab-task9-optimize.png]]

