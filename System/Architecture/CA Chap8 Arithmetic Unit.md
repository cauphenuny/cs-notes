---
aliases:
---

---

全加器逻辑：
$$
\begin{align}
S&=(\neg A\land \neg B\land C_{in}) \lor(\neg A\land B\land \neg C_{in})\lor(A\land \neg B\land \neg C)\lor(A\land B\land C_{in}) \\
&=\text{nand}(\text{nand}(\neg A,\neg B,C),\text{nand}(\neg A,B,\neg C),\text{nand}(A,\neg B,\neg C),\text{nand}(A,B,C))
\end{align}
$$
$$
\begin{align}
C_{out}&=(A\land B)\lor(A\land C_{in})\lor(B\land C_{in}) \\
&=\text{nand}(\text{nand}(A,B),\text{nand}(A,C),\text{nand}(B,C))
\end{align}
$$

可以看到 非门 $\to$ 与门 $\to$ 或门，或者 非门 $\to$ 与非门 $\to$ 与非门，延迟为 $3T$，产生进位的延迟为 $2T$

$g_{i}=a_{i} \land b_{i}= \neg(\text{nand}(a_{i},b_{i}))$

$p_{i}=a_{i}\lor b_{i}=\text{nand}(\neg a_{i},\neg b_{i})$

可见产生 $g_{i},p_{i}$ 需要两级门延迟

---

IEEE 754:

- float32
	1 符号
	8 阶码
	23 尾数
	_尾数中省略规格化数 1.xxxx 的 1_
	_阶码使用移码，但偏移量是 $2^{n-1}-1$ 不是 $2^{n-1}$_

- float64
	1 符号
	11 阶码
	52 尾数

注意：
- 阶码全零，尾数非零时，表示非规格化数，乘 $2^{-126}$，而不是 $2^{0-127}=2^{-127}$，此时尾数不补 1
- 阶码全零，尾数为零表示

手动计算 IEEE 浮点数：
_规格化到整数部分为 $1$ ，而不是 0.xxxx_

![[ieee754-127.png]]

---

使用3态反向器的D触发器：

![[D-flip.png]]

![[D-flop.png]]

---

超前进位加法器

门的fan-in有限制的情况下，每组的位数固定，总共需要的层数是 log 级别的，延迟 $O(\log N)$，其中 $N$ 是输入位数

---

华莱士树

乘法的过程中需要算 $O(N)$ 个部分积的和，每次合并一半，需要做 $O(\log N)$ 级加法，延迟为 $O(\log ^{2}N)$

但是合并的过程不需要计算加法($2\to {1}$)，可以用两个全加器实现 $O(1)$ 合并 4 个数到 2 个数

虽然加法是 $O(\log N)$，但是用全加器合并可以做到 $O(1)$，总复杂度 $\underbrace{ O(\log N) }_{ \text{合并} }+\underbrace{ O(\log N) }_{ \text{最后的加法} }=O(\log N)$

---

