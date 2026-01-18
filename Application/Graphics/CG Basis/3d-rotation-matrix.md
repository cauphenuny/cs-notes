---
title: 一种对 3D 旋转矩阵的直观理解
categories:
  - CS
  - Graphics
tags:
date: 2025-10-11 00:07:00
---

绕轴 $\mathbf{n}$ 旋转角度 $\alpha$ 的旋转矩阵是：

$$
\mathbf{R}_{\mathbf{n},\alpha}=\cos(\alpha)\mathbf{I}+(1-\cos(\alpha))\mathbf{n}\mathbf{n}^T+\sin\alpha \underbrace{ \begin{pmatrix}0 & -n_{z} & n_{y} \\ n_{z} & 0 & -n_{x} \\ -n_{y} & n_{x} & 0\end{pmatrix} }_{ \mathbf{N} }=\mathbf{I}+\sin(\theta)\mathbf{N}+(1-\cos\theta)\mathbf{N}^{2}
$$

其中，$\mathbf{N}=\hat{\mathbf{n}}=\begin{pmatrix}0 & -n_{z} & n_{y} \\ n_{z} & 0 & -n_{x} \\ -n_{y} & n_{x} & 0\end{pmatrix}$ 是向量 $\mathbf{n}$ 的反对称矩阵，满足 $\forall \mathbf{v}, \hat{\mathbf{n}}\mathbf{v}=\mathbf{n}\times\mathbf{v}$

图形学讲义给出的的旋转旋转矩阵的形式是
$$
\log \mathbf{R}_{\omega,\theta}=\theta\ \begin{pmatrix}0 & -\omega _{z} & \omega_{y} \\ \omega_{z} & 0 & -\omega_{x} \\ -\omega_{y} & \omega_{x} & 0\end{pmatrix}=\theta \hat{\omega}
$$

与普通的旋转矩阵 $\mathbf{R}$ 相比，这个形式看起来非常的简洁直观，但讲义里用了比较难受的方法证明：先证明 $\mathbf{R}$ ，然后证明这个矩阵指数形式等于 $\mathbf{R}$

> [!theorem] 三维旋转变换
> $\log \mathbf{R}_{\omega,\theta}=\theta\ \hat{\omega}$

> [!proof]
> 根据 [Rodrigues' Formula](https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula)，$R=I+\sin(\theta)A+(1-\cos(\theta)A^2$，其中 $A=\hat{\omega}$
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

证这个旋转矩阵 $\mathbf{R}$ 本身就比较复杂，再这样绕一遍证明 log 形式，证的时候还用了一些 trick，确实不是很优雅

---

那有没有直接从 log 形式出发的推导呢？想出了一个虽然不严谨但是挺直观的思路

转轴: $\boldsymbol{\omega} \quad(\lVert \boldsymbol{\omega} \rVert=1)$，旋转角度: $\theta$，待旋转的向量: $\mathbf{v}$

将旋转变换理解成刚体匀速旋转运动

$\hat{\boldsymbol{\omega}}=\begin{pmatrix}0 & -\omega _{z} & \omega_{y} \\ \omega_{z} & 0 & -\omega_{x} \\ -\omega_{y} & \omega_{x} & 0\end{pmatrix}$ 作用到 $\mathbf{v}$ 上可以生成一个跟 $\mathbf{v}$ 和 $\boldsymbol{\omega}$ 都垂直的方向，与旋转时的速度方向相同，此时的 $\boldsymbol{\omega}$ 为角速度

这里设角速度大小为 $1$，旋转时间 $\Delta t=\theta$，那么最终转过的角度就是 $\theta$
角速度作用到 $\mathbf{v}$ 上得到的 "速度" 是：$\hat{\boldsymbol{\omega}}\mathbf{v}$

$$
\begin{align}
\dfrac{\mathrm{d}\mathbf{v}}{\mathrm{d}t}&=\hat{\boldsymbol{\omega}}\ \mathbf{v} \\
\implies \mathbf{v}(t)&=\exp(\hat{\boldsymbol{\omega}}t)\mathbf{v} \\
\overset{t=\theta}{\implies} \mathbf{v_{\text{rot}}}&=\exp(\theta\hat{\boldsymbol{\omega}})\mathbf{v}
\end{align}
$$

得到变换矩阵：$\mathbf{R}_{\omega,\theta}=\exp(\theta \boldsymbol{\hat{\omega}})$