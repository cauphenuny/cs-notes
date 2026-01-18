#import "@local/theme-default:0.1.0": conf
#show: doc => conf(
  header: "2024年秋季组合数学",
  title: "第十讲",
  author: "袁晨圃",
  doc
)
#show ref: r => text(blue, r)
#import "@local/math-abbr:1.0.0": *
#import "@local/typst-sympy-calculator-preset:0.1.0": *

#import "@preview/ctheorems:1.1.3": *
#let anscolor = black
#show: thmrules.with(qed-symbol: $square$)
#let answer(..args) = text(anscolor, thmplain("answer", "答案").with(numbering: none)(..args))
#let proof(..args) = text(anscolor, thmplain("proof", "证明").with(numbering: none)(..args))
#let solution(..args) = text(anscolor, thmplain("solution", "解").with(numbering: none)(..args))
#let example = thmplain("example", "例").with(numbering: none)
#let definition = thmbox("definition", "定义", inset: (x: 1.2em, top: 1em))
#let theorem = thmbox("theorem", "定理", fill: rgb("dff3f9"))
#let trick = thmbox("trick", "技巧", fill: rgb("f8e8e8")).with(numbering: none)
#let corollary = thmbox("corollary", "推论", base: "theorem", fill: rgb("#e8f8e8")).with(numbering: none)
#let lemma = thmbox("corollary", "引理", base: "theorem", fill: rgb("#e8f8e8")).with(numbering: none)
#let conclusion = thmbox("conclusion", "结论",fill: rgb("#dff3f9")).with(numbering: none)
#let problem = thmbox("problem", "例", fill: rgb("#e8e8e8"))
#let variant = thmbox("variant", "变式", base: "problem", fill: rgb("#f4f4f4"))
#let exercise = thmbox("exercise", "", base_level: 0, titlefmt: strong, fill: rgb("#f4f4f4"))

#let splitline = line(start: (10%, 0pt), length: 80%, stroke: 0.3pt)
#let wrong = text(red)[$times$]

= 分拆数

分拆数的生成函数

$P(x)=&(1+x+x^2+dots.c)-> 1/(1-x)\
&(1+x^2+x^4+dots.c)->1/(1-x^2)\
&(1+x^3+x^6+dots.c)->1/(1-x^3)$

$P(x)=sum_(n>=0) P(n) x^n = product_(k>=1) 1/(1-x^k)$

定义$D(n)$(D: for different)表示将$n$拆成不同的几个数的方案数

例：$D(1)=1, D(2)=1, D(3)=2, D(4)=2$

定义$O(n)$(O: for odd)表示将$n$拆成几个奇数的和的方案数

例：$O(1)=1, O(2)=1 space(2=1+1), O(3)=2 space(3=3=1+1+1), O(4)=2 space(4=1+3=1+1+1+1)$

*下面证明$D(n)=O(n)$*

_代数证明_

由于不含偶数项，所以$O(n)$的生成函数$sum_(n>=1) O(n)x^n=product_(k>=0) 1/(1-x^(2k+1)) $

由于每一个数只能用一次，所以$D(n)$的生成函数为

$sum_(n>=1) D(n)x^n = (1+x)(1+x^2)(1+x^3)(1+x^4)dots.c = product_(k>=1)(1+x^k)$

转化为证明$product_(k>=1)(1+x^k) = product_(k>=0) 1/(1-x^(2k+1))$

$(1+x)(1+x^2)(1+x^3)(1+x^4)dots.c = cancel(1-x^2)/(1-x) dot cancel(1-x^4)/cancel(1-x^2) dot cancel(1-x^6)/(1-x^3) dot cancel(1-x^8)/cancel(1-x^4)dot dots.c = 1/(1-x) dot 1/(1-x^3) dot 1/(1-x^5) dots.c$

_组合证明_

考虑$n=6$

$6=1+5=2+4=1+2+3$

$1+5=3+3=1+1+1+3=1+1+1+1+1+1$

$D(n)$映射到$O(n)$

将$6$写成奇数乘二的幂次：$6=3times 2 => 3+3$

将$1, 5$写成奇数乘二的幂次：$1=1times 1, 5 = 5 times 1=>1+5$

将$2, 4$写成奇数乘二的幂次：$2=1times 2, 4 = 2 times 2=>(1+1) + (1+1+1+1)$

将$1, 2, 3$写成奇数乘二的幂次：$1=1times 1, 2 = 1 times 2, 3 = 3 times 1=>(1+1)+3$

$O(n)$映射到$D(n)$

考虑$1+1+1+1+1+1:$

$1times 6 = 1 times 4 + 1 times 2 quad=>4+2$（将$6$拆成二进制表示）

$1+1+1+3: 1times 3 + 3 times 1$

$1 times 2^0+1times 2^1+3 times 2^0 quad => 1 + 2 + 3$

为什么拆成二的幂次：要么对于同一个奇数，低位的$0$数目不同，要么是不同的奇数，所以一定是不同的两个数

= 勃兰特-切比雪夫定理

$forall x > 1, (x, 2x)$中必定存在一个素数

由斯特林公式

$binom(2n, n) = ((2n)!)/(n!n!) = (sqrt(2pi n) ((2n)/e)^(2n))/(sqrt(2pi n) (n/e)^n)tilde 2^(2n)/sqrt(n)$

使用反证法得出若定理不成立则$binom(2n, n)$远小于$2^(2n)/sqrt(n)$

$binom(2n, n) = (2n!)/(n!n!) = product_(p in "prime"\ 1<=p<=2n) p^?$

定义$h_p (m)=m!$里有多少个$p$因子，即：$max_k (p^k|m!)$

$binom(2n, n)=(2n!)/(n!n!) = product_(p in "prime"\ 1<=p<=2n) p^(h_p (2n) - 2h_p (n))$

若$n..2n$没有素数则$binom(2n, n)=product_(p in "prime"\ 1<=p<=n)p^(h_p (2n) - 2 h_p (n))$

$h_p (n) = sum_(k>0) floor(n/p^k)$

高斯取整函数的性质

+ $floor(x+n)=floor(x)+n$

+ $x-1 < floor(x)<=x < floor(x)+1$

+ $floor(x)+floor(y)<=floor(x+y)$

$h_p (n) &= product_(1<=p<=n) p^(h_p (2n) - 2 h_p (n)) = sum_(k>=1) (floor((2n)/p^k) - 2 floor(n/p^k))\
&=underbrace((product_(p <= sqrt(2n))dots.c), A) underbrace((product_(sqrt(2n)<p<= 2/3 n)dots.c), B) underbrace((product_(2/3 n < p <= n)dots.c), C)$

先考虑$C: 2/3 n < p <= n$

$sum_(k>=1)(floor((2n)/p^k) - 2floor(n/p^k)) = 0$

$2n < 3p quad 2 <= (2n)/p < 3$

// TODO:

$=>C=1$

再考虑$A: p <= sqrt(2n)$

$sum_(k>=1) (floor(2n/p^k) - 2 floor(2n/p^k))<= sum_(k=1)^(ceil(log_p 2n)) 1 = ceil(log_p 2n) <= log_p (2n) +1$

$A:p^(h_p (2n) - 2h_p (n)) <= p^(ceil )$
