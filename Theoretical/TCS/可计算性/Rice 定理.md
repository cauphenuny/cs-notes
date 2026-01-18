> [!def] 语言类
> 设 $\mathcal{P}$ 是图灵可识别语言上的一个集合
> 若 $\mathcal{P}$ 是空集或者包含所有 RE 语言，则称 $\mathcal{P}$ 是平凡的

> [!def] $L_{\mathcal{P}}$
> 定义语言 $L_{\mathcal{P}}=\{\langle M \rangle | M \text{ is a turing machine, }L(M) \in \mathcal{P}\}$，$L(M)$ 是 $M$ 识别的语言

> [!theorem] Rice
> 若 $\mathcal{P}$ 不平凡，则 $L_{\mathcal{P}}$ 不可判定

> [!proof]
> 若 $\emptyset \not\in \mathcal{P}$，设 $\langle N \rangle\in L_{\mathcal{P}}$（随便选一个）
> 对于给定的 $M,w$ 构造 $M'$ ：对于输入 $\tau$，$M'$ 执行 $M(w)$ 的过程，若能执行完则继续执行 $N(\tau)$。由上一行构造，可知 $N$ 识别的语言属于 $\mathcal{P}$，所以 $L(M')\not\in \mathcal{P}\implies M(w)\uparrow$
> 形式化地，这是一个可计算函数 $f:\langle M,w \rangle \mapsto \langle M' \rangle$ 
> 这样，可以将 Halt$_{\text{TM}}$ 多一[[规约]]到 $L_{\mathcal{P}}$
> $$L_{\mathcal{P}}(f(\langle M,w \rangle))=L_{\mathcal{P}}(\langle M' \rangle)=\begin{cases}
1 \quad &L(M')\in \mathcal{P} \implies M(w)\downarrow \\
0 & L(M')\not\in\mathcal{P} \implies M(w) \uparrow
\end{cases}=\text{Halt}(\langle M,w \rangle )$$

可以直接地证明 [[规约#应用]] 中的一些定理