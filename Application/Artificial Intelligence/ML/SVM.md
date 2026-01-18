## SVM

> [!def] 间隔 Margin
> 离超平面最近的点到超平面的距离
> 间隔越大，泛化性越强

> [!def] 分类超平面
> 考虑线性分类器 $f(\mathbf{x};\mathbf{w},b)=\text{sgn}(\mathbf{w}^T\mathbf{x}+b)$，分类超平面是 $\{ \mathbf{x}|\mathbf{w}^T\mathbf{x}+b=0 \}$ 定义为分类超平面

> [!def] 典型分类超平面
> $\mathbf{w},b$ scale 后平面不变，所以可以适当缩放 $\mathbf{w},b$ 使得距离平面最近的点 $\mathbf{x}$ 满足 $\lvert \mathbf{w}^T\mathbf{x}+b \rvert=1$

> [!def] 支持向量
> 离分类超平面最近的向量 $\mathbf{x}$ （即：位于典型分类超平面上）

---

**求解 Margin 最大的典型分类超平面**：

![[margin.png|406x333]]

$$
\begin{align}
\text{margin}&=\dfrac{1}{2} \times \left( \dfrac{\mathbf{w}}{\lVert \mathbf{w} \rVert } \right)^T (\mathbf{x}^{(+)}-\mathbf{x}^{(-)}) \\
&=\dfrac{1}{2\lVert \mathbf{w} \rVert } \times (\mathbf{w}^T \mathbf{x}^{(+)}-\mathbf{w}^T \mathbf{x}^{(-)}) \\
&=\dfrac{1}{2\lVert \mathbf{w} \rVert }(1-(-1)) \qquad (\text{recall: }\mathbf{w}^T\mathbf{x}^{(\pm)}+b=\pm1) \\
&=\dfrac{1}{\lVert \mathbf{w} \rVert }
\end{align}
$$

所以，最大化间隔 $\Longleftrightarrow$ 最小化 $\lVert \mathbf{w} \rVert$

约束条件：$\mathbf{w}^T \mathbf{x}^{(i)}+b \begin{cases} \geq +1 \text{ if } y^{(i)}=+1 \\ \leq-1 \text{ if }y^{(i)}=-1\end{cases}$

即：$y^{(i)}(\mathbf{w}^T\mathbf{x}^{(i)}+b)\geq {1}$

总结：优化目标：$\min \lVert \mathbf{w} \rVert ^{2},\text{s.t.} y^{(i)}(\mathbf{w}^T\mathbf{x}^{(i)}+b)\geq {1}$

---

拉格朗日乘子法

$$
\min_{\mathbf{w}}f(\mathbf{w}), \quad \text{s.t. }g_{i}(\mathbf{w})\leq 0, i=1\dots k; h_{j}(\mathbf{w})=0,j=1\dots l
$$

拉格朗日型：
$$
L_{p}(\mathbf{w},\boldsymbol{\alpha},\boldsymbol{\beta})=f(\mathbf{w})+\sum_{i=1}^k \alpha_{i}g_{i}(\mathbf{w})+\sum_{j=1}^l\beta_{j}h_{j}(\mathbf{w})
$$
$\alpha\geq {0},\beta:$ 拉格朗日乘子

原始问题等价于 $$
\min_{\mathbf{w}}\max_{\alpha\geq 0,\beta} L_{p}(\mathbf{w},\alpha,\beta)
$$
注意：条件隐式满足，因为 $\mathbf{w}$ 确定后若存在 $g_{i}>0$ 或 $h_{i}\neq {0}$，可以通过控制 $\alpha,\beta$ 使得 $L_{p}$ 达到 $+\infty$，从而会被 $\min_{\mathbf{w}}$ 排除

在此基础上，可以证明问题等价性

![[svm-opt.png]]

SVM 的问题满足 **强对偶定理**，可以交换 min,max，并且解满足 KKT 条件：
+ $\partial L_{p}(\mathbf{w},\alpha,\beta)=0$
+ $a_{i}g_{i}=0,\forall i$ （互补松弛条件）

将导数条件 $\mathbf{w}=\sum_{i=1}^n \alpha_{i}y^{(i)}\mathbf{x}^{(i)};\sum_{i=1}^{n}\alpha_{i}y^{(i)}=0$ 带回式子，得到

$$
\max_{\alpha\geq 0}\left( -\dfrac{1}{2}\sum_{i}\sum_{j}\alpha_{i}\alpha_{j}y^{(i)}y^{(j)}(x^{(i)})^{T}x^{(j)}+\sum_{i}\alpha_{i} \right)
$$
$$
\text{s.t. }\sum_{i} \alpha_{i}y^{(i)}=0
$$
此时优化复杂度与 $n$ 相关，与维度无关

接下来求 $w,b$:
$\mathbf{w}=\sum_{i=1}^{n}\alpha_{i}y^{(i)}x^{(i)}$
$b$: 互补松弛条件 $\alpha_{i}[1-y^{(i)}(\mathbf{w}^{T}x^{(i)}+b)]=0$，**若 $\alpha_{i}>0$，则 $y^{(i)}(\mathbf{w}^{T}x^{(i)}+b)=1$，样本 $i$ 是支持向量**

任选一个支持向量可以算出 $b$，用全部支持向量数值稳定性更好

判别函数（展开 $w$，与下文核方法对应）：
$$
f(\mathbf{x})=\left(\sum_{x^{(i)}\in\text{SV}}\alpha_{i}y^{(i)}({\mathbf{x}^{(i)}})^T\mathbf{x}\right)+b
$$

_手动求解的例子：看讲义_

---

## 核方法

核函数：将两个向量映射为实数值的对称连续函数 $K(\cdot,\cdot):\mathbb{R}^d\times \mathbb{R}^{d}\to \mathbb{R}$

e.g. $K(x_{1},x_{2})=x_{1}^Tx_{2}$

可以不用知道 非线性变换 $\Phi$ 的形式直接计算出 $\Phi(x_{1})^T\Phi(x_{2})$

> [!def] 多项式核函数
> $K(x^{(i)},x^{(j)})=\big((x^{(i)})^Tx^{(j)}+1\big)^q$，q是多项式次数

_q=2,d=2的例子：看讲义_

> [!def] 高斯核函数
> $K(x,x')=\exp\left( - \dfrac{\lVert x-x' \rVert^{2}}{2\sigma^{2}} \right)$
> 高斯核函数隐含的特征空间无限维，没有 $\phi$ 的解析表达式

---

## 软间隔

提高泛化性：软间隔

$y^{(i)}(\mathbf{w}^{T}x^{(i)}+b)\geq 1-\xi_{i}$ 其中 $\xi_{i}\geq {0}$ 是松弛变量

$\xi_{i}=0$：分类正确
$0<\xi_{i}<1$：分类正确，但模型没有把握
$\xi_{i}>1$：分类错误

优化问题变为：
$$
\min \dfrac{1}{2}\lVert \mathbf{w} \rVert ^{2}+C\sum_{i=1}^{N}\xi_{i}
$$
$$
\text{s.t. }y^{(i)}(\mathbf{w}^{T}x^{(i)}+b)\geq 1-\xi_{i}; \quad\xi_{i}\geq 0
$$

$C$: 正则化参数

所有 $\xi>0$ 的样本点都是支持向量（$\xi>0$ implies $y^{(i)}(\mathbf{w}^{T}x^{(i)}+b)=1-\xi_{i}$, otherwise $\xi$ is able to be $0$）

![[svm-result.png]]


---

## 附录

附录：对于 SVM 也是 ERM (经验风险最小化) 的推导：

**支持向量机（SVM）软间隔形式** 与其 **无约束优化形式（使用 hinge loss）** 的等价关系推导：

---

## 🧩 一、上半部分：带松弛变量的约束优化（软间隔 SVM）

$$
\begin{aligned}
\min_{\mathbf{w},b,\boldsymbol{\xi}} \quad & \frac{1}{2}\|\mathbf{w}\|^2 + C\sum_{i=1}^N \xi_i \\
\text{s.t.} \quad & y^{(i)}(\mathbf{w}^\top \mathbf{x}^{(i)} + b) \ge 1 - \xi_i, \\
& \xi_i \ge 0, \ \forall i.
\end{aligned}
$$

其中：
- $\mathbf{w}, b$：模型参数；
- $\xi_i$：松弛变量（表示允许的间隔违反程度）；
- $C$：平衡间隔宽度与误分类惩罚的超参数。

---

## ⚙️ 二、从约束优化到无约束优化

由约束条件可得：

$$
y^{(i)}(\mathbf{w}^\top \mathbf{x}^{(i)} + b) \ge 1 - \xi_i 
\quad \Rightarrow \quad 
\xi_i \ge 1 - y^{(i)}(\mathbf{w}^\top \mathbf{x}^{(i)} + b)
$$

同时还有 $\xi_i \ge 0$，因此：

$$
\xi_i \ge \max(0, 1 - y^{(i)}(\mathbf{w}^\top \mathbf{x}^{(i)} + b))
$$

在最优解处，为使目标函数最小，我们必然取最小可行的 $\xi_i$，即：

$$
\xi_i^* = \max(0, 1 - y^{(i)}(\mathbf{w}^\top \mathbf{x}^{(i)} + b))
$$

---

## 🧮 三、代回原目标函数

将 $\xi_i^*$ 代入原优化目标：

$$
\begin{aligned}
\min_{\mathbf{w}, b} \quad 
& \frac{1}{2}\|\mathbf{w}\|^2 + C \sum_{i=1}^N \xi_i^* \\
= & \frac{1}{2}\|\mathbf{w}\|^2 + C \sum_{i=1}^N \max(0, 1 - y^{(i)}(\mathbf{w}^\top \mathbf{x}^{(i)} + b))
\end{aligned}
$$

---

## 📉 四、得到无约束形式（Hinge Loss）

$$
\min_{\mathbf{w}, b} 
\sum_{i=1}^N [1 - y^{(i)}(\mathbf{w}^\top \mathbf{x}^{(i)} + b)]_+ + \lambda \|\mathbf{w}\|^2
$$

其中：
- $[z]_+ = \max(0, z)$ 为 **hinge loss（合页损失）**；
- 常数 $\lambda$ 与 $C$ 成反比（通常 $\lambda = \tfrac{1}{2C}$ 或类似比例）。

---

## 🧠 五、直观理解

| 形式 | 数学表达 | 含义 |
|------|-----------|------|
| 约束形式 | 有 $\xi_i$ 和不等式约束 | 明确控制误分类样本的容忍度 |
| 无约束形式 | 使用 hinge loss | 把违反约束的样本自动惩罚进去 |

**Hinge loss 的几何意义：**
- 若样本被正确分类且 $y(\mathbf{w}^\top\mathbf{x}+b) \ge 1$，损失为 0；
- 若样本位于间隔内或被分错，损失线性增加。

---

✅ **结论：**

上半部分的约束优化问题

$$
\min \frac{1}{2}\|\mathbf{w}\|^2 + C\sum \xi_i
$$

等价于下半部分的无约束优化问题

$$
\min \sum [1 - y^{(i)}(\mathbf{w}^\top \mathbf{x}^{(i)} + b)]_+ + \lambda \|\mathbf{w}\|^2
$$

其中 $\lambda$ 与 $C$ 仅有比例差异。