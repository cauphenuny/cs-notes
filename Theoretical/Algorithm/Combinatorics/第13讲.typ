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

= Ramsay Theory

证明$R(3,4)<=10:$

考虑$v1$连出的$9$条边，要么红边数量$>=4$要么蓝边数量$>=6$

+ 红边$>=4:$

  考虑连到的$4$个点之间的边

  如果有红边，则形成红色$K3$，反之这四个点形成蓝色$K4$

+ 蓝边$>=6:$

  考虑连到的$6$个点形成的子图

  由于$R(3,3)=6$

  若是红色$K3$，则已满足条件

  若是蓝色$K3$，则加入$v1$点，得到蓝色$K4$，满足条件

证明$R(3, 4)<=9:$

hint: 只多了一个$3$红$5$蓝的case，而且对于所有点，都引出$3$红$5$蓝，这合法吗？

#let splitline = line(start: (10%, 0pt), length: 80%, stroke: 0.3pt)

#splitline

#theorem[
  $ R(n, m)<=R(n-1, m)+R(n, m-1) $
]

#proof[
  令$t = R(n-1, m)+R(n, m-1)$

  考虑$K_t$的一个节点$v1$连出的边

  要么红边$>= R(n-1, m)$，要么蓝边$>=R(n, m-1)$（抽屉原理）

  假设引理成立，考虑红边$>=R(n-1, m)$的情况，子图中要么有蓝色$K_m$，要么有红色$K_(n-1)$，加入$v1$点后变成红色$K_n$
]

#corollary[
  $R(n, m) <= binom(n+m-2, n-1)$
]

#proof[
  初值$R(n, 2)=n$跟杨辉三角一样

  递推关系$R(n,m)<=R(n-1,m)+R(n,m-1)$与杨辉三角一样
]

#example[
  $R(3, 3)<=binom(4, 2)=6$

  $R(4, 4)<=binom(6, 3)=20$

  $R(n, n)<=binom(2n-2, n-1) tilde (2^(2n))/sqrt(n)$
]

*考虑$R(n,n)$的下界：*

构造$n-1$个红色$K_(n-1)$，不同子图之间的边都染蓝色

此时显然不存在红色$K_(n)$

蓝色$K_n$也不存在，因为若选出$n$个点，必有两个点属于同一个字图（抽屉原理），则这两个点之间的边是红色，所以不存在蓝色$K_n$

== Probabilitic Method 非构造性方法证明存在性

*考虑$R(n,n)$的一个非构造性下界：*

$R(n,n)>=N=(2^(n/2) dot n)/(2e)$

对每条边独立染色，$p_"红"=p_"蓝"=1/2$

一个图$G$是好的：$exists.not "Red" K_n, exists.not "Blue" K_n$

转换为证明 $Pr(G "is good")>0$（因为是古典概型）

$Pr(G "is good") = 1 - Pr(G "is bad")$

#let KR = $exists "Red" K_n$
#let KB = $exists "Blue" K_n$

$Pr(G "is bad") = Pr(KR union KB) <= Pr(KR) + Pr(KB) = 2 Pr(KR)$

$Pr(KR) &= Pr(union.big_(1<=i1<i2<dots.c<i_n<N) v_(i1), v_(i2), ..., v_(i_n) "is a red" K_n)<= binom(N, n) (1/2)^(n/2)\
&<= ((N e)/n)^n (1/2) ^ ((n(n-1)) slash 2)\
&<= (2^(n/2)/2)^n (1/2)^((n^2-n) slash 2) = 1/(2^(n slash 2))$

所以$Pr(G "is bad") = 2 dot 1/(2^(n slash 2)) < 1$

== 扩展至$R(n,m,p)$

$("Red" K_n) "or" ("Blue" K_n) "or" ("Yellow" K_n)$

类似地

$R(n,m,p)<=R(n-1,m,p)+R(n,m-1,p)+R(n,m,p-1)$