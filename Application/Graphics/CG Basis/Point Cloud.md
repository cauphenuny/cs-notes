点云
- $(x,y,z)$ 坐标集合，可能有法向信息，有法向信息的是面元

---

## 点云对齐：ICP

贪心，每一步的迭代求出当前旋转和缩放:
```
def ICP_iter(X, Y):
	// 求最近点
	proj = {x: Y.findnearst(x) for x in X}
	// 求变换使得最近点尽量匹配
	return solve_argmin([R, t], lambda R, t: norm([Rx + t - proj[x] for x in X]))
```

比较依赖于初值

问题：非均匀采样，导致相邻点 $x_{i},x_{j}$ 之间 对应的 $y_{i},y_{j}$ 方向差距很大，最小化点之间距离不是很好

优化一下，把距离投影到法向量方向 $\operatorname{argmin}_{R,t}\lVert (Rx_{i}+t-y_{i})^{T}n_{y_{i}} \rVert$

---

## 法向估计&去噪 

求 $P$ 的法向量：找到离 $P$ 最近的 $k$ 个点，最小化 平面到这些点的距离 
$$
n_{\text{optimal}}=\arg\min_{\lVert n \rVert=1}\sum_{i=1}^{k}( (p_{i}-P)^{T}n )^{2}=\arg\min_{\lVert n \rVert =1}\sum_{i=1}^{k}n^{T}Cn
$$

带约束$(n^{T}n=1)$ 的优化问题，使用 lagrange 乘子法

$\mathcal{L}(n,\lambda)=n^TCn-\lambda(n^{T}n-1)$

对 $n$ 求梯度，令 $\mathcal{L}'(n,\lambda)=0$

化简得 $Cn=\lambda n$，其中 $C=\sum_{i=1}^{k}(p_{i}-P)(p_{i}-P)^T$

所以最优法向量是特征向量
最小距离是特征值(?)


可以根据特征值判断当前区域噪声水平
如果 $\lambda_{\max}\gg\lambda_{\min}$，那么噪声较少（主成分明显，点云分布在平面附近）
反之，说明处在噪声区域

---

## 隐式曲面

对于一个函数 $f:\mathbb{R}^n\to \mathbb{R}$ ，可以确定一个曲面，对于 $x$ 点有 $f(x)>0\implies$ $x$ 在曲面外部，$f(x)<0\implies$ $x$ 在曲面内部，$f$ ：指标函数

从点云建立隐式曲面：

$f(x)=\sum_{p_{i}}(x-p_{i})n_{p_{i}}$

直观地，函数 $f$ 的梯度方向与法向量方向相同

---

## PointNet

点云：置换不变性

多元函数中的 $\max(\dots),\text{sum}(\dots)$ 具有置换不变性

将坐标输入 MLP，然后再通过 max 聚合特征

处理几何变换一致性：学习一个生成变换矩阵的 T-Net

