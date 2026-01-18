#import "@local/theme-default:0.1.0": conf
#show: doc => conf(
  header: "2024年秋季组合数学",
  title: "第七讲",
  author: "袁晨圃",
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

= 容斥原理

#problem[
  排列$[1...2n]$，其中$forall k$有$2k-1$和$2k$不相邻
]

#solution[
  $A_1={1, 2 "相邻"}, A_2={3, 4 "相邻"}, ... A_n = {2n-1,2n "相邻"}$

  $abs(A_i) = (2n-1)! dot 2$

  $&abs(ovl(A_1) sect ovl(A_2) sect dots.c sect ovl(A_n))\ 
  &=(2n)! - binom(n, 1) dot 2 dot (2n-1)! + binom(n, 2) dot 2^2 dot (2n-2)! +... + binom(n, n)(-1)^n dot 2^n dot n!\
  &=sum_(k=0)^n (-1)^n binom(n, k)2^k (2n-k)!$
]
#variant[
  改为圆排列
]

#problem[
  $40$ 人一人一封信，每个人可以开$20$封信，开到自己的即为成功，求所有人均成功的最大概率及策略
]

#solution[

  策略：第$i$个人先看$i$号信，若内容不是$i$(假设是$k$)，则继续看$k$号信，重复以上过程

  #example[
    设$i$号信封内容为$a_i$

    $mat(delim: "[", a_i, 2, 1, 4, 5, 3, 6; i, 1, 2, 3, 4, 5, 6)$

    转换为置换圈组：${1, 2}, space {3, 4, 5}, space {6}$ $=>$ 此时成功
  ]

  则如果有一个置换圈$C$长度超过$n/2$，则失败，反之成功.

  $Pr(max_(C in pi) abs(C) > n/2) = (sum_(n/2 <= k <= n) underbrace(binom(n, k)(k-1)!, C"中元素") underbrace((n-k)!, "剩下"n-k"个元素的排列")) dot 1/n! = sum_(n/2<=k<=n) 1/k tilde ln n - ln n/2 = 2$

  注意用到了一个条件：最多只可能存在一个超过$n/2$的置换圈
]

#problem("选做题")[
  若每个人只允许看$n/4$个信封(or $n/3$, anyway)，能做到的最好成功概率是多少?
]

= 斯特林数 Stirling Number

== 第一类斯特林数

=== 定义

#definition[
  $S_1(n, k)$: $n$个元素的置换中，满足用有向图表示之后刚好有$k$个圈的置换数量
]

=== 递推关系


+ $S_1(n, 1) = (n-1)!$

+ $S_1(n, 2)$:枚举$1$所在的圈长度$k$

  $S_1(n, 2) = sum_(k=1)^(n-1) underbrace(binom(n-1, k-1)(k-1)!, "1所在圈剩余的元素")(n-k-1)! = 
  sum_(k=1)^(n-1) (n-1)!/(n-k) = (n-1)! sum_(k=1)^(n-1) 1/k = (n-1)! dot H(n-1)$

  其中$H$是调和级数

+ $S_1(n + 1, k)$

  考虑$1$号元素

  + 单独成环$=>S_1(n, k-1)$

  + 插入某个已经存在的环中，可以插在任意一个元素后面 $=>n times S_1(n, k)$

  $S_1(n+1, k) = S_1(n, k-1) + n dot S_1(n, k)$

+ $S_1(n, n-1) = binom(n, 2)$

+ $S_1(n, n) = 1$

=== 代数定义

$x^underline(n) := x(x-1) dots.c (x-n+1)$

$x^underline(n) = sum_(k=0)^n S_1(n, k) x^k (-1)^(n+k)$

或 $x^overline(n)=sum_(k=0)^n S_1(n,k)x^k$