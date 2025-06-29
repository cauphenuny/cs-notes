一个布尔公式称为是可满足的(satisfiable), 如果存在变元的一组赋值，使得该公式的值等于 1.

> [!def] SAT 问题
> SAT, 布尔公式可满足性问题：任给一个公式，判断是否可满足
> $\text{SAT}=\{ \langle \phi \rangle\mid \phi\text{是可满足的布尔公式} \}$

> [!theorem]
> $\text{SAT}\in\text{NP}$
> ref: [[多项式时间复杂性#NP]]

> [!def] 文字(Literal)
> 变量或者变量的否定

> [!def] 子句
> 若干个文字的或（析取, disjuctive）
> $C=x_{i_{1}}\lor \bar{x}_{i_{2}}$

> [!def] CNF
> 若干个子句的与
> $C_{1}\land C_{2}\land C_{3}\dots \land C_{n}$

> [!theorem]
> 对任意布尔函数 $f:\{ 0,1 \}^{d}\to \{ 0,1 \}$
> 存在 CNF $\varphi$ s.t. $\varphi=f$

> [!proof]
> 对于布尔函数 $f$，用 DNF 写出 $f$
> 两边取非，$\bar{f}\to f$，DNF $\to$ CNF

> [!def] CNF-SAT
> For CNF $\varphi,\exists \pi,\varphi(\pi)=1$ ?

> [!def] 3-SAT
>
> > [!def] 3-CNF
> > 每个子句都是三个文字形式的 CNF
>
> $3\text{SAT}=\{ \langle \phi \rangle\mid \phi\text{是一个可满足的 3CNF 公式} \}$

> [!theorem]
> $3\text{SAT}\leq_{p}\text{CLIQUE}$
> ref: [[多项式时间复杂性#^446e36|CLIQUE]], [[多项式时间复杂性#^1d4e2d|多项式时间规约]]

> [!proof]
> 构造 $G$ 包含 $k$ 组节点，每组3个节点，对应一个子句，每个节点用对应的文字 $x, \lnot x$标记
> 连接两个 $G$ 中两个不同节点，但
> - 同一三元组内节点不连接
> - 有相反标记的两个节点不连接 $x \not\leftrightarrow \lnot x$
> 有 $k$ 团就代表着存在一种赋值使得每一个子句中至少有一个 1，所以整体的 3-CNF 可满足。

![[CLIQUE.png]]

> [!theorem] 
> SAT 是 NP 完全的

^c561f8

> [!example]
> 将线性方程组有解问题 LES 规约到 SAT:
> 
> > [!def] LES
> > $$ \begin{cases} x_{1}+x_{2} \pmod 2 \\ x_{1}+x_{2}+\dots=0 \\ x_{2}+x_{3}=1 \end{cases} \quad \mapsto \{ \text{无解，有解} \} $$
> 
> 减小方程规模：$[x_{1}+x_{2}+\cdots+x_{n}=1]\Longleftrightarrow \lor_{i=1}^n (x_{1}+x_{2}+\cdots+x_{i}+y=0 \land y+x_{i+1}+x_{i+2}+\cdots+x_{n}=1)$（考虑前 $i$ 个 $x$ 的和是否是 1
> 将每一个方程写成一个 CNF

> [!theorem]
> $\forall L \in\text{NP},L\leq_{p}\text{SAT}$

