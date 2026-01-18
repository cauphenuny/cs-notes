
> [!def] Logistic Regression
> 
> Train data: $\{ (\mathbf{x}^{(i)},y^{(i)},i=1\dots n) \}\sim P_{x,y}$
> (output $y^{(i)}\in \{ 0,1 \}$)
> 
> Loss Function: $l_{0-1}(f;\mathbf{x},y)=\mathbb{I}_{[\text{sgn} \circ f(x) \neq y]}$
Risk: $R(f)=\mathbb{E}_{x,y}l_{0-1}(f;x,y)$

适用于二分类问题的连续函数：sigmoid

![[sigmoid.png|429x219]]

$p(y=1|x)=g(\mathbf{w}^T\mathbf{x})=\dfrac{1}{1+\exp(-\mathbf{w}^T\mathbf{x})}\coloneqq f_{w}(x)$

$g(z)=\dfrac{1}{1+\exp(-z)}$: logistic 函数

$\dfrac{t}{1-t}$: 几率 odds

$\log \dfrac{t}{1-t}$: 对数几率 log odds logits, or logit function of $t$ 

$\ln \dfrac{p(y=1|x)}{1-p(y=1|x)}=\mathbf{w}^T\mathbf{x}$

