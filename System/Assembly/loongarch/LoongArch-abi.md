
|项目|LoongArch ABI|RISC-V ABI|
|---|---|---|
|参考标准|**LoongArch ELF psABI**（Loongson 自定义）|**RISC-V ELF psABI**（RISC-V Foundation 公共规范）|
|浮点协定|LP64D（带双精度 FPU） / LP64F（单精度） / LP64（纯整数）|同样 LP64D / LP64F / LP64|
|工具链|GCC ≥ 12，binutils ≥ 2.36 支持|GCC ≥ 10，binutils ≥ 2.35 支持|
|内核支持起始|Linux 5.19 起主线合入|Linux 5.3 起主线合入|

---

## 寄存器命名与参数传递规则对比

### 1️⃣ 通用寄存器（GPR）

|**寄存器功能类别**|**编号**|**RISC-V 别名 (编号)**|**LoongArch 别名 (编号)**|**职责 (调用者/被调用者保存)**|**备注**|
|---|---|---|---|---|---|
|**恒定零**|0|zero (x0)|zero (r0)|不适用 (N/A)|始终为 0 的硬连线寄存器。|
|**返回地址**|1|ra (x1)|ra (r1)|RISC-V: 调用者保存/ 被调用者使用（通常在序言中保存） LoongArch: 调用者保存 (No)|用于存储子程序调用后的返回地址。|
|**栈指针**|2-3|sp (x2)|sp (r3)|RISC-V: 被调用者保存 (Callee-saved) LoongArch: 被调用者保存 (Yes)|指向当前堆栈帧的顶部/底部。|
|**线程指针/TLS**|2-4|tp (x4)|tp (r2), u0 (r21)|RISC-V: 被调用者保存 (Callee-saved) LoongArch: 不适用 (Unused) / 不适用 (Unused)|用于访问线程本地存储 (TLS) 数据。|
|**全局指针**|3|gp (x3)|无专用|被调用者保存 (Callee-saved)|RISC-V 用于访问静态/全局数据。 LoongArch 通常没有专用的 gp。|
|**函数返回值**|10-11|a0 (x10), a1 (x11)|v0 (r4), v1 (r5)|调用者保存 (Caller-saved)|存储函数调用的返回值 (最多两个)。|
|**函数参数**|10-17|a0-a7 (x10-x17)|a0-a7 (r4-r11)|调用者保存 (Caller-saved)|用于传递前 8 个函数参数。|
|**临时寄存器**|5-7, 28-31|t0-t6 (x5-x7, x28-x31)|t0-t8 (r12-r20)|调用者保存 (Caller-saved)|用于临时计算，函数调用无需保存。|
|**被调用者保存**|8-9, 18-27|s0-s11 (x8-x9, x18-x27)|s0-s8 (r23-r31)|被调用者保存 (Callee-saved)|用于存储需要在函数调用中保留的值，被调用者必须保存/恢复。|
|**帧指针**|8 或 22|fp / s0 (x8)|fp (r22)|被调用者保存 (Callee-saved)|用于指向当前堆栈帧的固定位置。|

🟢 **结论**：  
两者寄存器功能语义几乎完全对应，但 LoongArch 使用传统 MIPS 风格命名和布局；  
RISC-V 则更简洁、连续。

---

### 2️⃣ 调用约定（Calling Convention）

|项目|LoongArch LP64D ABI|RISC-V LP64D ABI|
|---|---|---|
|参数传递|`$a0`–`$a7`，其余入栈|`a0`–`a7`，其余入栈|
|返回值|`$a0`, `$a1`|`a0`, `a1`|
|栈增长方向|向低地址增长|向低地址增长|
|栈对齐|16 字节|16 字节|
|调用者保存寄存器|`$t0`–`$t8`, `$a0`–`$a7`|`t0`–`t6`, `a0`–`a7`|
|被调用者保存寄存器|`$s0`–`$s9`, `$fp`|`s0`–`s11`, `fp`|
|返回地址保存|`$ra`|`ra`|
|Frame Pointer|`$fp` = `$s8` (r22)|`fp` = `s0` (x8)|

🟢 **结论**：  
从调用规则层面，LoongArch 基本是 “MIPS SysV ABI 的现代化版”，  
RISC-V 是更简化的 SysV 变体。函数参数顺序和寄存器用法上几乎兼容。

---

## 系统调用（syscall）ABI 差异（续）

|项目|**LoongArch**|**RISC-V**|
|---|---|---|
|调用指令|`syscall 0`|`ecall`|
|系统调用号寄存器|`$a7`（r11）|`a7`（x17）|
|参数寄存器|`$a0`–`$a5`|`a0`–`a5`|
|返回值|`$a0`|`a0`|
|错误返回机制|若返回值在 `[-4095, -1]` 之间，则视为错误并置 `errno`|相同|
|特殊寄存器修改|`$ra`, `$a7` 保留，`$a0` 改写|相同|
|内核陷入入口|`do_syscall_64()`（LoongArch 架构专用路径）|`do_syscall_64()`（RISC-V 路径）|

🔹 **区别小结：**

- LoongArch 使用 MIPS 传统的 `syscall` 指令；
    
- RISC-V 使用通用的 `ecall`；
    
- 参数、错误语义保持兼容，因此用户空间的 `glibc`/`musl` 实现几乎一致。
    

---

## 异常与中断栈布局（Trap Frame）

|项目|**LoongArch**|**RISC-V**|
|---|---|---|
|异常入口指令|`ertn` / `syscall` / `break`|`mret` / `ecall` / `ebreak`|
|异常入口寄存器保存|`pt_regs` 结构保存 `$r0–$r31`, `$csr_crmd`, `$csr_prmd`, `$csr_euen`, `$csr_ecfg`, `$csr_era` 等|`pt_regs` 保存 `x0–x31`, `status`, `epc`, `tval`, `cause` 等|
|返回地址寄存器|`$era`（Exception Return Address）|`sepc`（Supervisor Exception PC）|
|异常返回|`ertn`（Exception Return）|`sret`（Supervisor Return）|
|栈帧指针|`$sp` 16 字节对齐|`sp` 16 字节对齐|
|异常栈增长方向|向低地址|向低地址|

🔹 **区别要点：**

- LoongArch 的异常控制寄存器命名完全不同于 RISC-V（继承自 MIPS：CRMD、PRMD、ERA 等）。
    
- RISC-V 使用统一 CSR 命名（`sstatus`, `sepc`, `stval`, `scause`），更模块化。
    
- Linux 内核在两者上都抽象成 `struct pt_regs`，只是字段名不同。
    

---

## 信号与用户栈帧布局（Signal Frame）

|项目|**LoongArch**|**RISC-V**|
|---|---|---|
|信号栈布局|由 `setup_rt_frame()` 构造，包含 `siginfo_t`, `ucontext_t`, 寄存器上下文|同样由 `setup_rt_frame()` 构造|
|寄存器保存结构|`elf_gregset_t` / `elf_fpregset_t`|同名结构|
|返回用户态指令|`sys_rt_sigreturn` → 执行 `ertn`|`sys_rt_sigreturn` → 执行 `sret`|
|栈增长方向|向低地址|向低地址|
|对齐要求|16 字节|16 字节|

🔹 两者在信号 ABI 层**完全兼容 POSIX 语义**，仅底层硬件返回指令不同。

---

## 浮点寄存器与矢量 ABI

|项目|**LoongArch LP64D**|**RISC-V LP64D**|
|---|---|---|
|浮点寄存器|`$fa0`–`$fa7`（f0–f7）|`fa0`–`fa7`（f10–f17）|
|额外保存寄存器|`$fs0`–`$fs7`（f22–f29）|`fs0`–`fs11`（f8–f9, f18–f27）|
|参数传递|浮点参数在 `$fa0`–`$fa7`，与整数寄存器独立|同理|
|矢量扩展|LASX/LASX2（128-bit/256-bit SIMD）|RVV（RISC-V Vector，长度可变）|
|矢量寄存器命名|`vr0`–`vr31`|`v0`–`v31`|
|调用保存策略|矢量寄存器调用者保存|RVV ABI 可配置（caller/callee 保存）|

🔹 **核心差异**：

- LoongArch 的 SIMD（LASX/LASX2）是固定宽度向量；
    
- RISC-V 的 RVV 是可变长度（VLEN 可调）；
    
- 因此二者在用户态 SIMD ABI 上**完全不兼容**。
    

---

## ELF 与重定位差异（psABI 层）

|项目|**LoongArch ELF psABI**|**RISC-V ELF psABI**|
|---|---|---|
|ELF Machine ID|`EM_LOONGARCH (258)`|`EM_RISCV (243)`|
|重定位类型|`R_LARCH_*`（如 `R_LARCH_RELATIVE`, `R_LARCH_64`）|`R_RISCV_*`（如 `R_RISCV_RELATIVE`, `R_RISCV_64`）|
|PLT/GOT 机制|兼容 ELF64 System V|同上|
|动态链接器路径|`/lib64/ld-linux-loongarch-lp64d.so.1`|`/lib64/ld-linux-riscv64-lp64d.so.1`|

---

## 总体差异总结

|层级|LoongArch|RISC-V|相似度|
|---|---|---|---|
|调用规则|类似 MIPS|简洁 SysV|★★★★★|
|syscall 机制|`syscall 0`|`ecall`|★★★★☆|
|CSR/异常返回|MIPS 风格（CRMD/PRMD/ERA）|RISC-V 风格（sstatus/sepc）|★★☆☆☆|
|浮点/矢量|LASX 固定宽度|RVV 可变长度|★★☆☆☆|
|ELF/重定位|自定义 R_LARCH|标准 R_RISCV|★★★★☆|
|工具链生态|Loongson 自行维护|RISC-V Foundation 统一标准|★★★☆☆|

---

✅ **一句话总结：**

> **Linux/LoongArch ABI** ≈ “MIPS64 SysV ABI 的现代延续版”；  
> **Linux/RISC-V ABI** ≈ “极简 SysV ABI 的新设计”。
> 
> 两者在用户空间层面（C ABI、系统调用参数）几乎兼容，  
> 但在**异常模型、CSR 命名、SIMD/浮点 ABI**上完全不同。

---

如果你想，我可以把这份对比改成 **“LoongArch vs RISC-V ABI 差异图表 PDF”**（带寄存器布局和调用栈示意图）方便引用到技术文档或论文中。  
是否要我帮你生成？