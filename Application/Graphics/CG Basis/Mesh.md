## 网格光滑

拉普拉斯光滑

$\mathbf{p}_{i}^{(t+1)}\gets \mathbf{p}_{i}^{(t)}+\lambda\Delta \mathbf{p}_{i}^{(t)}$

$\Delta \mathbf{p}_{i}^{(t)}= \dfrac{1}{\lvert N_{i} \rvert}\left( \sum_{j\in N_{i}}\mathbf{p}_{j} \right)-\mathbf{p}_{i}$ （用临近的点平均值更新当前点）


## 网格简化

- 顶点删除
- 边压缩
- 面片收缩

### 局部平坦性：Schroeder的局部判别准则

### 二次误差

计顶点 $v_{a}$ 的相邻面片是 $\text{plane}(v_{a})$

$$
\text{plane}(v_{a})=\{ (a,b,c,d)\mid a,b,c,d\text{ is the coeff of adjacent plane, and } a^{2}+b^{2}+c^{2}=1\}
$$

注意到 $a,b,c$ 就是法向量的系数，将点投影到法向量方向上计算距离来衡量 $v_{a}$ 移动到 $v$ 的误差：

$$
\begin{align}
\Delta(v_{a}\to v)
&=\sum_{p \in \text{plane}(v_{a})}(pv^{T})^{2} \\
&=\sum_{p \in \text{plane}(v_{a})}(pv^{T})(pv^{T}) \\
&=\sum_{p \in \text{plane}(v_{a})}(pv^{T})^{T}(pv^{T}) \quad \text{(因为} pv^{T}\text{是标量)} \\
&=\sum_{p \in \text{plane}(v_{a})}vp^{T}pv^{T} \\
&=v\left(\sum_{p \in \text{plane}(v_{a})}p^{T}p\right)v^{T} \\
&=vQ(v_{a})v^{T}
\end{align}
$$

对于某个特定顶点 $v_{a}$ 可以预处理 $Q$ 矩阵。

多点移动误差：合并 $(v_{1},v_{2})\to v$ 误差为 $\Delta(v)=\Delta(v_{1}\to v)+\Delta(v_{2}\to v)=v(Q(v_{1})+Q(v_{2}))v^{T}=vQv^{T}$

$$
\Delta=\begin{pmatrix}x & y & z & 1\end{pmatrix}\begin{pmatrix}q_{11} & q_{12} & q_{13} & q_{14} \\ q_{21} & q_{22} & q_{23} & q_{24} \\ q_{31} & q_{32} & q_{33} & q_{34} \\ q_{41} & q_{42} & q_{43} & q_{44}\end{pmatrix}\begin{pmatrix}x \\ y \\ z \\ 1\end{pmatrix}=\sum_{i=1}^{4}\sum_{i=1}^{4}v_{i}v_{j}q_{ij}
$$

求偏导 $\dfrac{\partial\Delta}{\partial x}=\dfrac{\partial\Delta}{\partial y}=\dfrac{\partial\Delta}{\partial z}=0$

展开得 
$$
\forall i \in \{1,2,3\}, \quad \sum_{j=1}^{4} v_{j}(q_{ij}+q_{ji})=0
$$
注意到 $Q$ 是对称的，可得

$$
\begin{cases}
q_{11}x+q_{12}y+q_{13}z+q_{14}w &= 0 \\
q_{21}x+q_{22}y+q_{23}z+q_{24}w &= 0 \\
q_{31}x+q_{32}y+q_{33}z+q_{34}w &= 0 \\
w &= 1
\end{cases}
$$
i.e. 
$$
\begin{pmatrix}
q_{11} & q_{12} & q_{13}  & q_{14}\\ q_{21} & q_{22} & q_{23}  & q_{24}\\ q_{31} & q_{32} & q_{33}  & q_{34} \\
0 & 0 & 0 & 1
\end{pmatrix}\begin{pmatrix}
x \\
y \\
z \\
w
\end{pmatrix}
=
\begin{pmatrix}
0 \\
0 \\
0 \\
1
\end{pmatrix}
$$

> [!theorem] 矩阵求导公式
> $\dfrac{\partial (\mathbf{x}^{T}\mathbf{A}\mathbf{x})}{\partial \mathbf{x}}=(\mathbf{A}+\mathbf{A}^{T})\mathbf{x}$

## 三位形状描述

- spin image：绕某个点的法线，统计每个点到轴心的距离和高程分布，将3维转化为2维
