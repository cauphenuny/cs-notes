## 2D transform

Homogenous Coordinates:

expand dimension for describing translations.
$$
\begin{pmatrix}
x \\
y \\
1
\end{pmatrix}
$$

point:  w-coordinate is $1$
vector: w-coordinate is $0$

_operation is valid when w-coordinate is $1$ or $0$:_
vector $+$ vector $\to$ vector
point $-$ point $\to$ vector
point $+$ vector $\to$ point
point $+$ point $\to$ INVALID

$\begin{pmatrix}x \\ y \\ w\end{pmatrix}$ is the 2D point $\begin{pmatrix} x / w \\ y / w \\ 1\end{pmatrix},w\neq {0}$

![[Pasted image 20250925140024.png]]

## 3D transformations

Scale: ...
Translation: ...

Rotation:
$$
\mathbf{R}_{x}(a)=\begin{pmatrix}
1 & 0 & 0 & 0 \\
0  & \cos\alpha & -\sin\alpha & 0 \\
0 & \sin\alpha & \cos\alpha & 0 \\
0 & 0 & 0 & 1
\end{pmatrix}
$$

$$
\mathbf{R}_{y}(a)=\begin{pmatrix}
\cos\alpha & 0 & \sin\alpha & 0 \\
0 & 1 & 0 & 0 \\
-\sin\alpha & 0 & \cos\alpha & 0 \\
0 & 0 & 0 & 1
\end{pmatrix}
$$
$\mathbf{R}_{y}$ seems range.
However, if we regard this as $z-x$ rotate matrix, rather than $x-z$ rotate (exchange row/column), it seems reasonable.
$$
\mathbf{R}_{z}(a)=\begin{pmatrix}
 \cos\alpha & -\sin\alpha & 0 & 0 \\
\sin\alpha & \cos\alpha & 0  & 0\\
0 & 0 & 1 & 0 \\
0 & 0 & 0 & 1
\end{pmatrix}
$$

> [!def] Euler Angle
> $\mathbf{R}_{xyz}(\alpha,\beta,\gamma)=\mathbf{R}_{x}(\alpha)\mathbf{R}_{y}(\beta)\mathbf{R}_{z}(\gamma)$
> $\alpha:$ roll
> $\beta$: pitch
> $\gamma$: yaw
> ![[roll-pitch-yaw.png|248x196]]

> [!def] 外积矩阵
> 外积矩阵：$\mathbf{n}\mathbf{n}^T$
> 效果：$\mathbf{n}\mathbf{n}^T\mathbf{v}$ 得到 $\mathbf{v}$ 在 $\mathbf{n}$ 方向的分量（如果 $\mathbf{n}$ 是单位向量）
> $\mathbf{n}(\mathbf{n}^T\mathbf{v})=\mathbf{n}(\mathbf{n}\cdot \mathbf{v})$

> [!theorem] Rodrigues’ Rotation Formula
> Rotation by angle $\alpha$ around axis $n$
> $\mathbf{R}(\mathbf{n},\alpha)=\cos(\alpha)\mathbf{I}+(1-\cos(\alpha))\mathbf{n}\mathbf{n}^T+\sin\alpha \underbrace{ \begin{pmatrix}0 & -n_{z} & n_{y} \\ n_{z} & 0 & -n_{x} \\ -n_{y} & n_{x} & 0\end{pmatrix} }_{ \mathbf{N} }=\mathbf{I}+\sin(\theta)\mathbf{N}+(1-\cos\theta)\mathbf{N}^{2}$
> $\mathbf{N}$: hat operator, $\hat{\mathbf{a}}\mathbf{b}=\mathbf{a}\times \mathbf{b}$
> (Notice that $\mathbf{N}^{2}\mathbf{v}=\mathbf{n}\times(\mathbf{n}\times \mathbf{v})=(\mathbf{n}\cdot \mathbf{v})\mathbf{n}-(\mathbf{n}\cdot \mathbf{n})\mathbf{v}=(\mathbf{n}\cdot \mathbf{v})\mathbf{n}-\mathbf{v}$, so $\mathbf{N}^{2}=\mathbf{n}\mathbf{n}^T-\mathbf{I}$)
> 
> For vector $\mathbf{v}$:
> $\mathbf{v}_{\text{rot}}=\cos(\theta) \mathbf{v}+\sin(\theta)\mathbf{k}\times \mathbf{v}+(1-\cos\theta)\mathbf{k}\times(\mathbf{k}\times \mathbf{v})$
> 
> $\log \mathbf{R}(\mathbf{n},\alpha)=\alpha \begin{pmatrix}0 & -n_{z} & n_{y} \\ n_{z}  & 0 & -n_{x} \\ -w_{y} & w_{x} & 0\end{pmatrix}=\alpha \mathbf{N}$

^54d557

> [!proof]
> 将向量 $\mathbf{v}$ 分解成沿 axis $\mathbf{n}$ 方向和垂直 axis $\mathbf{n}$ 方向。
> 沿 axis 方向：$\mathbf{n}\mathbf{n}^T\mathbf{v}$
> 垂直 axis: 旋转作用于此，先将原向量缩放为 $\cos\alpha$倍，然后加入垂直分量 $\sin\alpha(\mathbf{n}\times \mathbf{v})$
> 结果：$\mathbf{R}(\mathbf{n},\alpha)\mathbf{v}=\mathbf{n}\mathbf{n}^T\mathbf{v}+\cos\alpha(\mathbf{I}-\mathbf{n}\mathbf{n}^T)\mathbf{v}+\sin\alpha(\mathbf{n}\times \mathbf{v})$

