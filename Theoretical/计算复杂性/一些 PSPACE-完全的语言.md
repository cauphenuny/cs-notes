## TQBF
> [!def] 量词化布尔公式
> 带量词的布尔公式

> [!def] TQBF 问题
> $\text{TQBF}=\{ \langle \phi \rangle|\phi\text{是真的全量词化布尔公式} \}$

> [!theorem]
> TQBF 问题是 PSPACE 完全的

> [!proof]
> - $\text{TQBF}\in\text{PSPACE}$
> 	$T=$ 对输入 $\langle \phi \rangle,\phi$ 是一个全量词化的布尔公式：
> 	1. 若 $\phi$ 不含量词，则直接计算，为真_接受_，反之_拒绝_
> 	2. 若 $\phi=\exists x\psi$，则在 $\psi$ 上递归调用，分别用 $0/1$ 替换 $x$，只要有一个接受则 _接受_
> 	3. 若 $\phi =\forall x \psi$，类似递归，全接受则_接受_
> - $\text{TQBF}$ 是 $\text{PSPACE}$ 难的
> 	类似[[一些 NP-完全的语言#^c561f8|库克定理]]，构造一个真假值代表是否存在PSPACE图灵机 $M$ 计算历史的量词布尔公式
> 	$\phi_{c_{1},c_{2},t}$ 表示 $M$ 在最多 $t$ 步内从 $c_{1}$ 到达 $c_{2}$
> 	目标是构造 $\phi_{c_{\text{start}},c_{\text{accept}},h}$，其中 $h=2^{df(n)}$，$d$ 是一个常数，使得 $M$ 格局数不超过 $2^{df(n)}$，$f(n)=n^k$
> 	- 若 $t=1$，构造要么 $c_{1}=c_{2}$，要么 $c_{1}$ 一步可达 $c_{2}$
> 	- 若 $t>1$，构造 $\exists m_{1},\forall(c_{3},c_{4})\in\{(c_{1},m_{1}),(m_{1},c_{2})\}[\phi_{c_{3},c_{4},t/2}]$
> 		可以将 $\forall x \in \{ y,z \}[\dots]$ 换为 $\forall x[(x=y\lor x=z)\to\dots]$
> 		$A\to B\equiv \lnot A \lor B$
> 		$A=B\equiv A\to B\land B\to A$
> 	递归的每一层增加公式跟格局长度是线性关系的，总递归 $\log 2^{df(n)}$=$O(f(n))$层，所以公式长度为 $O(f^2(n))$


## 公式博弈

## 广义地理学
