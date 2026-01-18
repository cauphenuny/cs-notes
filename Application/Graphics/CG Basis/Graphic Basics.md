ref: chap2
## 三角网格模型

> [!def] 三角网格
> 顶点集合 $V=(v_{1},v_{2},\dots,v_{n})$
> 面片集合 $F=(f_{1},f_{2},\dots,f_{m})$
> $F$ 中的每个面片 $f_{i}$ 都是 $V$ 中顶点构成的空间三角形：
> $f_{1}=(v_{a_{1}},v_{b_{1}},v_{c_{1}}), f_{2}=\dots$


求点的法向量：求出周围的所有面的法向量，然后按某种方法平均，算术/按角度加权/按面积加权

---

## 光照模型

Lambert: 漫反射
![[lambert.png]]
Half Lambert: 提高整体亮度，把Lambert从 $[0, 1]$ 映射到 $[0.5,1]$

Phong光照模型

- 漫反射光效果
- 镜面反射光效果
- 环境光效果
![[phong.png]]
L 是入射光；R 是反射光；N 是物体表面的法向量；V是视点方向；H是L 和 V 夹角的角平分线方向。
模拟镜面反射$I_{s}=I_{i}K_{s}\cdot(R\cdot V)^n$，$n$ 控制集中程度

总发光强度：
$$
I=\underbrace{ I_{i}K_{a} }_{ \text{环境光} }+\underbrace{ I_{i}K_{s}\cdot(R\cdot V)^{n} }_{ 镜面反射 }+\underbrace{ I_{i}K_{d}\cdot(L\cdot N) }_{ 漫反射 }
$$

---

## 明暗处理（shading）

Gouraud/Phong shading: 分别对色彩和法向进行差值

Gouraud:
1. 计算多边形定点法向量
2. 用上文光照模型算顶点光强
3. 用双线性插值计算多边形表面每个像素的明暗

Phong:
Gouraud是先用顶点的法向量算出光强，然后对光强插值，不如Phong直接求出一般点的法向量然后再计算光强精确。

---

## 变换

> [!info] 常见变换
> - 刚体变换 (Rigid-body)
> - 相似变换 (Similarity)
> - 线性变换 (Linear)
> - 仿射变换 (Affine)
> - 投影变换 (Projective)

### 刚体变换

包括：不变平移、旋转及复合，**保持度量（长度、角度、大小）**

变换矩阵：正交矩阵，$R^TR=I$

### 相似变换

刚体变换 $+$ 均衡缩放

### 线性变换

$$
\begin{align}
L(p+q)&=L(p)+L(q) \\
aL(p)&=L(ap)
\end{align}
$$

包括：不变、旋转、缩放（不一定均衡）、对称、错切(Shear)

![[linear-transforms.png]]

### 仿射变换

**保持直线以及直线之间的平行**

线性变换 $+$ 相似变换

### 投影变换

**保持直线**

![[proj-trans.png]]

---
## 齐次坐标

用四维数组表示三维空间的点和向量

平移

$$
\begin{pmatrix}
x' \\
y' \\
z' \\
1
\end{pmatrix}
=
\begin{pmatrix}
1 & 0 & 0 & t_{x} \\
0 & 1 & 0 & t_{y} \\
0 & 0 & 1 & t_{z} \\
0 & 0 & 0 & 1
\end{pmatrix}
\begin{pmatrix}
x \\
y \\
z \\
1
\end{pmatrix}
$$
缩放
$$
\begin{pmatrix}
x' \\
y' \\
z' \\
1
\end{pmatrix}
=
\begin{pmatrix}
s_{x} & 0 & 0 & 0 \\
0 & s_{y} & 0 & 0 \\
0 & 0 & s_{z} & 0 \\
0 & 0 & 0 & 1 \\
\end{pmatrix}
\begin{pmatrix}
x \\
y \\
z \\
1
\end{pmatrix}
$$

旋转

ref. [[Transforms#3D transformations]]

设转轴是 $\omega=(\omega_{x},\omega_{y},\omega_{z})^T, \lVert w \rVert=1$

Hat operator: $\hat{a}b=a\times b$

$\hat{\omega}=\begin{pmatrix}0 & -\omega _{z} & \omega_{y} \\ \omega_{z} & 0 & -\omega_{x} \\ -\omega_{y} & \omega_{x} & 0\end{pmatrix}$

设旋转矩阵是 $R_{\omega,\theta}$，则有

> [!theorem] 三维旋转变换
> $\log \mathbf{R}_{\omega,\theta}=\theta\ \hat{\omega}$

> [!proof]
> 根据 [[Transforms#^54d557|Rodrigues' Formula]]，$R=I+\sin(\theta)A+(1-\cos(\theta)A^2$，其中 $A=\hat{\omega}$
> 设 $\mathbf{L}=\theta\hat{\omega}$
> 展开 $\exp(\mathbf{L}):$
> $\exp(\mathbf{L})=I+A\theta+\dfrac{A^{2}\theta^{2}}{2!}+\dots$
> 因为 $A$ 是 $3\times {3}$ 反对称矩阵，所以 $A^3=-A$，所以
> $$
\begin{align}
\exp(\mathbf{L})&=I+\left( \theta- \dfrac{\theta^3}{3!}+ \dfrac{\theta^{5}}{5!} \right)A+\left( \dfrac{\theta^{2}}{2!}- \dfrac{\theta^{4}}{4!}+\dots \right)A^2 \\
&=I+\sin\theta A+(1-\cos\theta)A^2 \\
&=R
\end{align}
> $$
> 所以 $\log \mathbf{R}=\mathbf{L}=\theta \hat{\omega}$

一个更简单的证明思路

把旋转过程看成物理上的匀速旋转运动，转轴 omega 方向就是角速度方向，$\mathbf{v}$ 是一个在旋转的向量。

$\hat{\omega}$ 作用到 $\mathbf{v}$ 上可以生成 $\omega \times \mathbf{v}$，一个跟 $\mathbf{v}$ 和 $\omega$ 都垂直的方向，直观地类似旋转中的 "速度" 方向，这里的 $\omega$ 可以看成某种形式的 “角速度”（类比物理意义上的旋转运动 $v=\omega \times r$）

角速度乘时间等于角度，这里设时间为 $\Delta t=1$，那么角速度大小就是 $\theta$，作用到 $\mathbf{v}$ 上得到的 "速度" 向量是：$\theta\hat{\omega}\mathbf{v}$

$$
\begin{align}
\dfrac{\mathrm{d}\mathbf{v}}{\mathrm{d}t}&=\theta\hat{\omega}\mathbf{v} \\
\implies \dfrac{\mathbf{v_{\text{rot}}}}{\mathbf{v}}&=\exp(\theta\hat{\omega}) \\
\implies \mathbf{v_{\text{rot}}}&=\exp(\theta\hat{\omega})\mathbf{v}
\end{align}
$$

直接得出变换矩阵是 $\exp(\theta\hat{\omega})$ ?

---

### 法向变换

![[vert-trans.png]]
计算切平面，然后通过切平面计算法向量
设法向量是 $\mathbf{n}$，切平面任一向量为 $\mathbf{v}$，变换矩阵是 $M$
$$
\begin{align}
n^Tv&=0 \\
n^T(M^{-1}M)v&=0 \\
(n^TM^{-1})(Mv)&=0 \\
(n^TM^{-1})v'&=0
\end{align}
$$
$$
n'=(n^TM^{-1})^T=(M^{-1})^Tn
$$
法向量变换矩阵：$(M^{-1})^T$

---

## 投影

正交投影：视角在无穷远处, e.g. $(x,y,z)\longrightarrow(x,y,0)$
透视投影：视角在有限远处, e.g. $(x,y,z)\longrightarrow((d/z)x, (d / z)y, d)$（视点在原点，投影到 $z=d$ 平面）

透视投影矩阵：
$$
\begin{pmatrix}
dx \\
dy \\
dz \\
z
\end{pmatrix}
=
\begin{pmatrix}
d & 0 & 0 & 0 \\
0 & d & 0 & 0 \\
0 & 0 & d & 0 \\
0 & 0 & 1 & 0
\end{pmatrix}
\begin{pmatrix}
x \\
y \\
z \\
1
\end{pmatrix}
$$


---

## 渲染管线

第一个部分：顶点着色器

顶点着色器中会作变换：

![[render.png]]


