---
aliases:
---

等待时间：周转时间 - 运行时间

所以 Round-Robin 算法 是需要把被抢占的时间也算在等待时间里面的。

不同的算法：

非抢占式调度:
- **F**irst **C**ome **F**irst **S**ervice
- **S**hort **T**ime to **C**omplete **F**irst

抢占式调度：
- **R**ound **R**obin: 轮流分配时间片，对应 FCFS
- **S**hort **R**emaining **T**ime to **C**omplete **F**irst：分配时间片给剩余时间最少的，对应 STCF

RR 示例：（时间片=20）

![[image.png]]


---


创建 $\to$ 就绪 $\to$ 运行 ($\to$ 等待) $\to$ 就绪 $\to$ 运行 $\to \cdots$ $\to$ 退出

等待：等待IO / sleep

---

`fork`: 克隆进程，共享代码段/数据段，Copy on Write.

虚地址不变，实际地址变化
```
int a = 0;

int main() {
    int rc = fork();
    if (rc == 0) {
        a = 1;
    } else {
        sleep(1);
    }
    printf("%d: %d at %p\n", getpid(), a, &a);
    return 0;
}
```

```
$ ./test
2614: 1 at 0x104620000
2613: 0 at 0x104620000
```

`exec`: 替换当前代码段/数据段

---

> [!info] fork
> **头文件与原型**
> 在 unistd.h 中声明。
> pid_t fork(void);
> 作用: 在当前进程中创建一个几乎完全相同的子进程。调用一次，返回两次：父
> 进程返回子进程的 PID，子进程返回 0。
>
> **返回值与错误**
>
> 父进程中：返回新建子进程的进程 ID (> 0)。
> 子进程中：返回 0。
> 出错：返回 -1（只在父进程里），并设置 errno，常见为
> EAGAIN（进程数或内核资源受限）或 ENOMEM（内存不足）。
>
> **父子进程关系与继承**
>
> 进程地址空间被复制（现代内核使用写时复制
> COW，实际物理页并不立刻拷贝）。
> 子进程继承大多数进程属性：环境变量、当前工作目录、umask、信号处理方式、
> 资源限制等。
>
> 子进程的挂起信号集被清空；信号处置（handler/忽略/默认）和阻塞掩码会继承。
> 线程：如果父进程是多线程，只有调用 fork
> 的那个线程会出现在子进程中，其它线程不会存在。
>
> **文件与标准 I/O**
>
> 所有已打开的文件描述符在子进程中继承，并引用相同的“打开文件描述”（open
> file description）。这意味着：
>
> 文件偏移量是共享的，在父子间相互影响（如一个读/写会移动另一个看到的偏移）。
>
> 打开状态（如 O_APPEND）共享。
> 建议在子进程中尽快使用 exec 系列并在 exec 前关闭不需要的
> fd，或给不希望继承的 fd 设置 FD_CLOEXEC（或打开时使用 O_CLOEXEC）。
> 标准 I/O 缓冲会被复制，若在 fork 前缓冲区里已有数据，父子进程各自 flush
> 可能导致重复输出。解决：在 fork 前 fflush(0)，或者子进程在不 exec
> 的情况下使用_exit() 退出避免再次冲刷缓冲。
>
> **与 exec、wait 的典型用法**
>
> 常见模式是 fork 之后在子进程中 exec*() 启动新程序，在父进程中
> wait/waitpid() 等待子进程结束。
> 在多线程程序中，fork 后到 exec 前只调用“异步信号安全”的函数；必要时使用
> pthread_atfork() 注册 atfork
> 处理器，避免在子进程里持有被其它线程锁住的互斥量。
>
> **常见陷阱**
>
> 多线程+fork：只有当前线程复制，持有的锁状态可能不一致；fork 后立即 exec
> 是最安全的。
> 标准 I/O 双重输出：fork 前 fflush。
> 共享文件偏移引发竞态：父子并发读写同一 fd 时需加锁或各自重新打开。
> 资源限制：RLIMIT_NPROC/控制组限制可能导致 EAGAIN。
> 退出方式：子进程不 exec 时应使用_exit(status) 而非
> exit(status)，避免再次运行 atexit 处理器和刷新父进程复制来的缓冲。

> [!example]
> ```c
> fflush(NULL);  // 避免缓冲重复输出
> pid_t pid = fork();
> if (pid < 0) {
>     perror("fork");
>     return 1;
> }
> if (pid == 0) {  // 子进程
>     printf("child: pid = % d, ppid = % d\n ", getpid(), getppid());
>     _exit(42);
> } else {
>     // 父进程
>     int status;
>     pid_t w = waitpid(pid, &status, 0);
>     if (w == -1) {
>         perror("waitpid");
>         return 1;
>     }
>     if (WIFEXITED(status)) {
>         printf("parent: child %d exit code=%d\n", pid, WEXITSTATUS(status));
>     } else if (WIFSIGNALED(status)) {
>         printf("parent: child %d killed by signal %d\n", pid, WTERMSIG(status));
>     }
> }
> ```

