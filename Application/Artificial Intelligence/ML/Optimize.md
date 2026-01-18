
> [!def] 风险
> $$
R(f)=\mathbb{E}_{x,y \sim P}l(f;x,y)
> $$

> [!def] Bayesian 最优风险：
> $$
f^*=\operatorname{argmin}_{f\in \mathcal{F}}\mathbb{E}_{x,y \sim P}l(f;x,y)
> $$

$l$ 为平方损失时，$f^*$ 有确定形式：条件期望 $f^*(x)=\mathbb{E}[y| x]$

> [!proof]
> $$
\begin{align}
R(f)&=\mathbb{E}_{x,y\sim P}(f(x)-y)^{2} \\
&=\mathbb{E}_{x,y\sim P}(f(x)-r^*(x)+r^*(x)-y)^{2} \\
&=\mathbb{E}(f(x)-r^*(x))^{2}+\mathbb{E}(r^*(x)-y)^{2}+\mathbb{E}_{x,y\sim P}((f(x)-r^*(x))(r^*(x)-y)) \\
&=\mathbb{E}(f(x)-r^*(x))^2+\mathbb{E}(r^*(x)-y)^{2}+\underbrace{ \cancel{ \mathbb{E}_{x_{0}\sim P}(f(x_{0})-r^*(x_{0}))\mathbb{E}_{y|x_{0}}(r^*(x_{0})-y) } }_{ \text{consider } r^* (x)=\mathbb{E}_{y|x}(x)} \\
&=\mathbb{E}(f(x)-r^*(x))^2+\mathbb{E}(r^*(x)-y)^2 \\
&\geq \mathbb{E}(r^*(x)-y)^{2} \qquad\text{when }f=r^*
\end{align}
> $$

