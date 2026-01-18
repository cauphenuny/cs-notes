## 锁的实现方法：

### 软件方法

**Dekker's Algorithm**

```c
request[0] = false, request[1] = false;
turn = 0 or 1;
do {
	request[THIS] = true;
	while (request[OTHER] == true) {
		if (turn != THIS) {
			request[THIS] = false;
			while (turn != THIS);
			request[THIS] = true;
		}
	}
	
	<<<CRITICAL SECTION>>>
	
	turn = OTHER;
	request[THIS] = false;
	
	<<<REMAINDER SECTION>>>
	
} while (true);
```

忙则等待：
某线程在临界区 Critical Section 时，它的 request一定是有1的，其他线程会被 `while (req[OTHER])` 卡住

空闲则入：
有 turn 表示优先级，低优先级的线程会先将 `req` 暂时取消

**Peterson**

```cpp
// common:
int turn;
bool request[];

// thread i:
do {
	request[THIS] = true;
	turn = OTHER; // 给其他线程
	while ( request[OTHER] && turn == OTHER);
		CRITICAL_SECTION;
	request[THIS] = false; 
		REMAINDER_SECTION;
} while (true);
```

多核情况下会出现问题：store buffer 和指令重排导致不同核心可见性不一致

e.g. 
thread0: 核心 1 先执行 `turn=1`，然后再执行 `request[0]=true`，在设置 request 的指令提交之前，`request[0]` 的结果对核心2不可见，thread1: 核心 2 执行 `request[1]=true, turn=0`，然后执行到 while cond, 此时 `request[0]=false`，跳过while，进入临界区。同时 thread0 由于 `turn=0` 也跳过 while，进入临界区。

两个线程同时进入临界区

## 原子指令

内存序：

---

_有原子指令的时候也需要关中断_：

```cpp
spin_lock::acquire() {
	// (enabled interrupt)
	
	while (test_and_set(lock));
	
	(intr) ---> func() {
		self.acquire(); // 申请同一个锁，此时中断关了，锁还申请不到，完全死锁
	}
}
```

---

## 死锁

死锁的必要条件：

- 互斥
- 占有且等待
- 不可抢占（资源不能被夺走，只能由持有者释放）
- 环路等待


---

### 信号量 semaphores

信号量：int，表示资源数量

两个原子操作
- P/Wait/Down
  ```c
  	P(s) {
  		while (s <= 0);
  		s--;
  	}
  	```
- V/Signal/Up
```c
V(s) {
	s++;
}
```

