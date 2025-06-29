#import "@local/theme-default:0.1.0": conf
#show: doc => conf(
  header: "2024秋季组合数学",
  title: "第八讲",
  author: "",
  doc
)
#import "@local/math-abbr:1.0.0": *
#import "@local/typst-sympy-calculator-preset:0.1.0": *

#import "@preview/ctheorems:1.1.2": *
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

#show ref: r => text(blue, r)

= 分拆数 Partition Number

#definition[
  $P(n)$将$n$分拆成几个数的和的方案数
]

#example[
  $2=2$

  $2=1+1$

  $P(2)=2$

  $3=3$

  $3=2+1$

  $3=1+1+1$

  $P(3)=3$
]


#definition[
  $P(n, k)eq.def {(x1, x2, ..., x_k)mid(|)x1+x2+dots.c+x_k = n, x1>=x2>=dots.c>=x_k>=1}$

  $P(n)=sum_(k=1)^n P(n, k)$
]

$P(n,1)=1$

$P(n, 2)=floor(n/2)$

$P(n, 3)=?$

$sum_(x3=0)^(floor(n/3))sum_(x2>=x3)^(floor((n-x3)/2)) 1$

== 分拆数的几何表示 Ferrers Diagram

$7=4+2+1 in P(7, 3)$

o o o o

o o

o 

也可以竖着分拆$7=3+2+1+1$,最大的数恰好是$k=3$

定义$Q(n, k)={(y1, y2, .., y_l) | n=y1+dots.c+y_l, y1=k, y1>=y2>=dots.c >= y_l>=1}$(最大数等于$k$)

得到$P(n,k)=Q(n,k)$

$P(n,k)$

考虑分拆$n=x1+x2+dots.c+x_k$的最后一个元素$x_k$

+ $x_k=1$

  贡献$P(n-1, k-1)$

+ $x_k>=2$

  例如

  o o o o o 

  o o 

  分割掉第一列

  o | o o o o 

  o | o 

  右侧方案数$P(n-k, k)$

  贡献$P(n-k, k)$

所以$P(n,k)=P(n-1,k-1)+P(n-k, k)$

== 对分拆数的估计

$P(n)tilde e^(c sqrt(n))$

$e^(c_1sqrt(n))<=P(n)<=e^(c_2 sqrt(n) log n)=n^(c_2 sqrt(n))$

下面证明$P(n)>=e^(c sqrt(n))$

定义$P(n, <=k) eq.def sum_(j=1)^n P(n, j)$

$S=floor(sqrt(n))+dots.c+3+2+1=((floor(sqrt(n))+1)floor(sqrt(n)))/2 <= n$

$n=n-S+floor(sqrt(n))+dots.c+3+2+1$

$floor(sqrt(n))+dots.c+3+2+1$每一个子集都可以对应一个$n$的分拆$n=n-(sum_(x in C)x) + sum_(x in C) x$

所以$P(n)>=sum_(k=1)^(sqrt(n)+1)P(n,k)>=2^(sqrt(n))$

然后证明$P(n)<= n^(c_2 sqrt(n))$

$n=x1+x2+dots.c+x_n$

将大于等于$sqrt(n)$的放进$A$，小于的放进$B$

$A$里面最多放$floor(sqrt(n))$个元素

$A$方案数$<=P("sum" A, floor(sqrt(n))) <= P(n, sqrt(n))$

$B$方案数$ <= Q("sum" B, floor(sqrt(n))) <= Q(n, floor(sqrt(n)))$

故$P(n)<=(P(n, floor(sqrt(n))))^2$

下面对$P(n,k)$给出一个上界

$P(n,k)<=abs({(x1, ... x_k) mid(|) x1+dots.c+x_k=n, x_i in NN}) = binom(n-1, k-1)quad$(考虑元素顺序)

$P(n, sqrt(n))<=binom(n-1, floor(sqrt(n))-1)tilde ((e n)/sqrt(n))^sqrt(n) = e^sqrt(n) sqrt(n)^(sqrt(n)) = e^(sqrt(n))e^(ln(sqrt(n)) sqrt(n)) = e^(sqrt(n)(1/2 ln(n) + 1))tilde n^(1/2 sqrt(n))$ // TODO:

#theorem[
  $(n/m)^m<=binom(n, m)<=((e n)/m)^m$
]

== 生成函数

$P(x)=sum_(n>=0)P(n)x^n$