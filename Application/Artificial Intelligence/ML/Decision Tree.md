## 主流程

1. 选择一个属性作为根节点，依据属性的可能取值建立分支
2. 按节点属性的取值，将数据划分成多个子集，分支下的每个节点对应一个子集
3. 对每个节点的子集，递归选择属性、进一步划分子集
4. 直到一个节点的子集里，全都样本都属于同一个类；或者所有属性都用完了

---

## 属性选择

> [!def] Entropy
> $$
H(X)=-\sum_{x \in \mathcal{X}}P(X=x)\log_{2}P(X=x)
> $$

> [!def] 条件熵
> $$
\begin{align}
H(Y|X)&=\sum_{x \in \mathcal{X}}P(X=x)H(Y|X=x) \\
&=-\sum_{x \in \mathcal{X}}P(X=x)\sum_{y \in \mathcal{Y}}P(Y=y|X=x)\log P(Y=y|X=x) \\
&=-\sum_{x \in \mathcal{X}}\sum_{y \in \mathcal{Y}}P(X=x,Y=y)\log P(Y=y|X=x)
\end{align}
> $$
> $H(Y|X)=H(Y)$ iff $X,Y$ 独立
> $H(Y|X)=0$ 当且仅当 $Y$ 的值完全由 $X$ 的值确定。

> [!def] 信息增益 Information Gain
> 考虑具有标签$\{1, … , K\}$ 和属性$\mathcal{A} ≔ \{A_{1}, \dots, A_{d}\}$的数据集 𝒟 ， 属性 $𝐴 ∈ \mathcal{A}$ 对于数据集 𝒟的信息增益为
> $$
\text{IG}(\mathcal{D},A)=H(\mathcal{D})-H(\mathcal{D}|A)
> $$
> 其中
> $$
H(\mathcal{D}|A)=\sum_{a \in \text{value}(A)} \dfrac{\lvert \mathcal{D}_{A=a} \rvert }{\lvert \mathcal{D} \rvert }H(\mathcal{D}_{|A=a})
> $$

最佳属性：能最大化当前节点对应的数据子集的属性（最小化 $H(\mathcal{D}|A)$）

> [!warning] 信息增益选择属性的潜在问题
> 信息增益偏好于选择取值可能性多的属性
> > [!example]
> > • 为一些描述企业客户的数据构建决策树
> > • 属性𝐴: 客户的信用卡id
> > • 属性𝐴的信息增益极高（人和id唯一绑定），但不是个好属性，因为根据已知客户的信用卡id对客户分类，不可能推广到我们以前从未见过的客户。因此构建决策树时，我们不希望用到这个属性。

解决方案：考虑属性 $A\in \mathcal{A}$ 的固有值，修正后得到增益率 Grain Ration $\text{GR}(\mathcal{D},A)=\dfrac{\text{IG}(\mathcal{D},A)}{\text{IV}(\mathcal{D},A)}$

$$
\text{IV}(\mathcal{D},A)\coloneqq-\sum_{a \in value(A)} \dfrac{\lvert D_{A=a} \rvert }{\lvert \mathcal{D} \rvert }\log_{2}\dfrac{\lvert D_{A=a} \rvert }{\lvert \mathcal{D} \rvert }
$$
（相当于拿 A 做标签的熵 $H(\mathcal{D})$?）

---

> [!def] 基尼系数
> $\text{Gini}(\mathcal{D})=\sum_{k}p_{k}(1-p_{k})=1-\sum_{k}p_{k}^{2}$
> $p_{k}$: $k$ 标签的概率
> 属性 $A$ 的基尼系数：
> $\text{Gini}(\mathcal{D},A)=\sum_{a\in value(A)} \dfrac{\lvert D_{A=a} \rvert}{\lvert \mathcal{D} \rvert}\text{Gini}(\mathcal{D}_{A=a})$

---
## 停止条件

停止条件：属性用完了，或者节点中全是同一类

可能会过拟合，选择pre-剪枝或 post-剪枝

前剪枝：把 train 分成 train 和 validation，验证集上决定是不是拆分训练集节点（如果验证集分类效果变好则拆分）

后剪枝：

对于所有内部节点：
+ 把从一个节点出发的子树替换成一个叶子节点
+ 新叶子节点的类别为训练集里该叶子节点样本里最多的类别
+ 计算验证集误差
+ 如果错误变少，则做这次剪枝
+ 否则不做剪枝，恢复该节点下的子树

后剪枝效果好，但需要更多时间

---

## 属性连续或缺失

连续：枚举所有的相邻采样值 $a_{i},a_{i+1}$，生成阈值 $T_{i}= \dfrac{a_{i}+a_{i+1}}{2}$，然后选择信息增益最大的阈值

$\text{IG}(\mathcal{D},A,t)=H(\mathcal{D})- \dfrac{\lvert D_{A\geq t} \rvert}{\lvert \mathcal{D} \rvert}H(D_{A\geq t})-\dfrac{\lvert \mathcal{D}_{A<t} \rvert}{\lvert \mathcal{D} \rvert}H(\mathcal{D}_{A<t})$

缺失：
![[attr-missing.png]]

拆分样本：

![[sample-split.png]]