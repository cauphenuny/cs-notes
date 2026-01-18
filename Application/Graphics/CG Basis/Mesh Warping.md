曲面变形
- 模型定义为空壳
- 变形定义在曲线曲面上
- _变形和网格表示紧耦合_

空间变形

---

## 曲面变形

Laplacian 坐标 

$(\mathbf{1}-\mathbf{D}^{-1}\mathbf{A})\mathbf{V}=\boldsymbol\delta$
$\boldsymbol{\delta}_{i}=v_{i}-\dfrac{1}{d}\sum v_{j}\text{ for } j \in\text{Neighbor}(i)$ ，记作 $L(v_{i})$
$\mathbf{D}$: 对角矩阵 $\mathbf{D}(i,i)=\text{deg}(i)$
$\mathbf{A}$: 邻接矩阵

直接求解最小能量：变换前后的Lap坐标的二次误差+变换后点的绝对坐标和目标点的坐标的二次误差

- 问题：无法处理旋转缩放不变性

加入旋转矩阵 $T$ ，形式化变形后和变形前的变换矩阵

$$
V'=\arg \min_{V'} \left( \sum_{i=1}^{n}\lVert L(V_{i}')-T_{i}(\delta_{i}) \rVert^{2} +\sum_{i=1}^{U}\lVert V_{i}'-u_{i} \rVert^{2} \right)
$$

给 $T_{i}$ 一个约束，限定为旋转+缩放

(二维情况如下)
$$
T_{i}=\underbrace{ \begin{pmatrix}
s & 0 & 0 \\
0 & s & 0 \\
0 & 0 & 1
\end{pmatrix} }_{ \mathbf{S} }
\underbrace{ \begin{pmatrix}
\cos\theta  & \sin\theta & 0 \\
-\sin\theta & \cos\theta & 0 \\
0 & 0 & 1
\end{pmatrix} }_{ \mathbf{R} }
$$


(三维情况如下，非线性)

$$
\mathbf{T}=\mathbf{S}\mathbf{R}=\mathbf{S}\exp \mathbf{H}=\mathbf{S}(\dots\text{(用一阶泰勒展开近似)})
$$

- 问题：基于迭代的方法求 $T$ 会导致局部最优，尺度变化大的时候无法做到均匀变换

---

## 体变形

- 复杂度与模型表示无关

- 可以适用于任何几何表示，不只是网格

### MLS 变形

仿射变换

对于每一对控制顶点 $p_{i}\to \hat{p}_{i}$，寻找最佳的变化从 $p_{i}$ 变为 $\hat{p}_{i}$

$$
\arg\min_{M,T}\sum_{i}\lvert (Mp_{i}+T)-\hat{p}_{i} \rvert ^{2}
$$

对于空间中的每个点 $v$，变换矩阵应该是不同的，intuitively，距离越远，控制影响越小，所以给上式加一个权重 

$$
M_{v}, T_{v}=\arg\min_{M,T}\sum_{i} \dfrac{1}{\lvert p_{i}-v \rvert }\lvert Mp_{i}+T-\hat{p}_{i} \rvert ^{2}
$$

选择不同的 $M$ 可以形成不同的变形效果，如果选一般矩阵的话可能无法保持 scale，造成不同区域缩放不一样。

相似MLS：
允许局部平移、旋转、缩放，可以防止形象剪切(shear)
$M=\begin{pmatrix}s & 0 \\ 0 & s\end{pmatrix}\begin{pmatrix}c & s \\ -s & c\end{pmatrix}=\mathbf{s}\mathbf{R}$

刚体MLS：
允许平移、旋转，不允许缩放
$M$ 只选择旋转阵 $\mathbf{M}=\begin{pmatrix}c & s \\ -s & c\end{pmatrix}=\mathbf{R},c^{2}+s^{2}=1$，这样能保持度量

_保持度量_: $\lVert Rv \rVert^{2}=\lVert v \rVert^{2}$

#### 问题

缩放的时候把整个空间都缩放了，可能造成不相关的模型部分的影响，应该考虑模型内部的距离，而不是空间欧式距离

### 包围盒变形

给模型构造一个包围盒，然后将模型内部坐标 $(x_{0},x_{1},\dots,x_{n})$ 用边界点坐标 $(\dfrac{1}{N}(w_{a}x_{a}+w_{b}x_{b}+\dots),\dots)$ 表示，得到重心坐标 $(w_{a},w_{b},\dots,)$

- 求和为1 $\sum_{i=1}^{n}w_{i}(x)=1$
- 单位可重建性 $\sum_{i=1}^{n}w_{i}(x_{i})(x_{i})=x$

### 调和坐标

拉普拉斯方程：$\nabla^{2}u=0$：每个点周围平均值等于这个点的值

$$
\begin{cases}
\nabla^{2}w=0 \\
w_{ii}=\delta_{ii}
\end{cases}
$$
