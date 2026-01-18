
> [!def] $\lambda$-term
> - variables ($x,y,z$) are $\lambda$-terms. 
> - Abstraction: if $M$ is a $\lambda$-term, $x$ is a var, then $\lambda x.M$ is a $\lambda$-term.
> - Application: if $M$, $N$ are $\lambda$-terms, then $(M\space N)$ is a $\lambda$-term.

$\beta$-reduction
$(λx.M)N→β​M[x:=N]$

> [!def] The Fixpoint Combinator Y
> $\mathbf{Y}:=\lambda f. (\lambda x.f(x\space x)\space (\lambda x.f(x \space x))$

^2a6c47

> [!theorem]
> For each $\lambda$-term $F$, $F(\mathbf{Y} F)=\mathbf{Y}\space F$

> [!proof]
> $$
\begin{aligned}
\mathbf{Y} F &= (\lambda f. (\lambda x.f(x\space x)\space (\lambda x.f(x \space x))) F\\
&=_{\beta} (\lambda x.F(x \space x))(\lambda x.F(x\space x))\\
&=_{\beta} F(x\space x)[x:=(\lambda x.F(x\space x))]\\
&=_{\beta} F((\lambda x.F(x\space x))(\lambda x.F(x\space x)))\\
&=_{\beta} F(\mathbf{Y} F)
\end{aligned}
 $$
