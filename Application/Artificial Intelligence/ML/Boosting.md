集成学习，用弱学习算法 boost 成一个强学习算法

Boosting 的问题：

- 优化目标 $l$ 
- 弱分类器集成权重 $\alpha_{t}$
- 每一轮的数据分布更新 $D_{t}$
- 应该学习多少个弱分类器 $T$

> [!def] AdaBoost
> 输入：$n$ 个样本 $\{ (x^1,y^1),\dots,(x^N,y^N) \}$，弱学习器 $h_{t}(x)$
> 最终分类器：$H(x)=\alpha_{1}h_{1}(x)+\dots+\alpha_{T}h_{T}(x)$
> 指数损失函数：$L_{\text{exp}}(H)=\sum_{i=1}^{n}\exp(-y^{i}H(x^{i}))$

---
 
指数损失函数的合理性：

最佳分类器 $H^{*}(x)=\dfrac{1}{2} \ln \dfrac{P(Y=1\mid x)}{P(Y=-1\mid x)}$

是满足
$\text{sign}(H^{*}(x))=\text{sign}\left( \dfrac{1}{2}\ln \dfrac{P(Y=1\mid x)}{P(Y=-1\mid x)} \right)=\operatorname{argmax}_{y\in \{ -1,1 \}}P(Y=y\mid x)$
的分类器

带入偏导

$\dfrac{\partial L_{\exp}(H)}{\partial H(x)}=-n_{+}(x)e^{-H(x)}+n_{-}(x)e^{H(x)}$ 其中 $n_{\pm}$ 是 $y=\pm {1}$ 的样本数量，令 partial diff 为0，则
$-n_{+}(x)e^{-H(x)}+n_{-}(x)e^{H(x)}=0\implies e^{-H(x)} \dfrac{n_{+}(x)}{n_{+}(x)+n_{-}(x)}=e^{H(x)} \dfrac{n_{-}(x)}{n_{+}(x)+n_{-}(x)}$，与 $H^*$ 形式一致

---

权重 $\alpha_{t}$

化简 $L_{\exp}(\alpha_{t}h_{t}\mid D_{t})=e^{-\alpha_{t}}(1-\varepsilon_{t})+e^{\alpha_{t}}\varepsilon_{t}$，其中 $\varepsilon_{t}=P_{x\sim D_{t}}(y\neq h_{t}(x))$

$\dfrac{\partial L_{\exp}(\alpha_{t}h_{t}\mid D_{t})}{\partial\alpha_{t}}=-e^{-\alpha_{t}}(1-\varepsilon_{t})+e^{\alpha_{t}}\varepsilon_{t}=0$

所以 $\alpha_{t}=\dfrac{1}{2}\ln\left( \dfrac{1-\varepsilon_{t}}{\varepsilon_{t}} \right)$

---

推导数据权值分布更新：

因为弱分类器只是一个 minimize 0-1 损失的简单东西，所以我们需要调制数据集的分布来让这个弱分类器对整体效果最好

$h_{t+1}$ 最小化 $L_{\text {exp }}\left(H_t+\alpha_{t+1} h \mid D\right)$

$$
\begin{aligned}
& L_{\text {exp }}\left(H_t+\alpha_{t+1} h \mid D\right)=\mathbb{E}_{x \sim D}\left[e^{-y\left(H_t(x)+\alpha_{t+1} h(x)\right)}\right] \\
&=\mathbb{E}_{x \sim D}\left[e^{-y H_t(x)} \mathrm{e}^{-y \alpha_{t+1} h(x)}\right] \\
& \simeq \mathbb{E}_{x \sim D}\left[e^{-y H_t(x)}\left(1-y \alpha_{t+1} h(x)+\frac{y^2 \alpha_{t+1}^2 h^2(x)}{2}\right)\right] \\
&=\mathbb{E}_{x \sim D}\left[e^{-y H_t(x)}\left(1-y \alpha_{t+1} h(x)+\frac{\alpha_{t+1}^2}{2}\right)\right] \quad(y=\pm {1},h(x)=\pm 1)\\
& 
\begin{aligned}
h_{t+1} & =\arg \min _h L_{e x p}\left(H_t+\alpha_{t+1} h \mid D\right) \\
& =\arg \max _h \mathbb{E}_{x \sim D}\left[e^{-y H_t(x)} y h(x)\right]\\
&=\arg \min _h \mathbb{E}_{x \sim D_{t+1}} l_{0-1}(x, y) \\
\end{aligned} 

\begin{align}
\text { 令 } &D_{t+1}(x) \propto D(x) e^{-y H_t(x)} \\
& \implies D_{t+1}(x) \propto D_t(x) e^{-\alpha_t y h_t(x)}
\end{align}
\end{aligned}
$$

直观理解，
$$
\text{weight}=\begin{cases}
\exp(-\alpha_{t})\leq 1 &\text{if } h_{t}(x)=y \\
\exp(\alpha_{t})\geq 1& \text{if }h_{t}(x) \neq y
\end{cases}
$$

