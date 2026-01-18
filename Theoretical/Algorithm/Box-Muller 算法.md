从分布中采样的一般方法：

$u \leftarrow \text{sample}(\mathcal{U}(0,1))$
The $F_{x}$ is cumulative distribution function.
$\implies F^{-1}_{x}(u)$ is the prob density function. 

直观理解：
$\dfrac{\,\mathrm{d}F}{\,\mathrm{d}x}=p(x)$
考虑 $\,\mathrm{d}u$ 采样的 $x=F_{x}^{-1}(u)$ 的变化范围 $\,\mathrm{d}x=\,\mathrm{d}u \cdot \dfrac{\,\mathrm{d}F^{-1}}{\,\mathrm{d}u}=\,\mathrm{d}u \cdot \dfrac{\,\mathrm{d}x}{\,\mathrm{d}F} = \dfrac{\,\mathrm{d}u}{p(x)}$
概率密度: $\dfrac{\,\mathrm{d}u}{1-0} \big/ \dfrac{\,\mathrm{d}u}{p(x)}=p(x)$

通过 box-muller 算法从正态分布中采样：

直接采样二维的，更好积分
