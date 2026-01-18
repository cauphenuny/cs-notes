#import "@local/typst-sympy-calculator-preset:0.1.0": *
#import "@local/theme-default:0.1.0": conf
#show: doc => conf(
  header: "2024年秋季学期组合数学 第三讲",
  title: "第三讲",
  author: "",
  doc
)

#import "@preview/ctheorems:1.1.2": *
#show: thmrules.with(qed-symbol: $square$)
#let example = thmplain("example", "例").with(numbering: none)
#let solution = thmplain("solution", "解").with(numbering: none)
#let answer = thmplain("solution", "答案").with(numbering: none)
#let proof = thmproof("proof", "证明")
#let definition = thmbox("definition", "定义", inset: (x: 1.2em, top: 1em))
#let _inset = (y: 0.6em, x:1.2em)
#let theorem = thmbox("theorem", "定理", fill: rgb("dff3f9"))
#let trick = thmbox("trick", "技巧", fill: rgb("f8e8e8"), inset: _inset).with(numbering: none)
#let corollary = thmbox("corollary", "推论", base: "theorem", fill: rgb("#e8f8e8")).with(numbering: none)
#let lemma = thmbox("corollary", "引理", base: "theorem", fill: rgb("#e8f8e8")).with(numbering: none)
#let conclusion = thmbox("conclusion", "结论",fill: rgb("#dff3f9")).with(numbering: none)
#let problem = thmbox("problem", "例", fill: rgb("#f4f4f4"))
#let exercise = thmbox("exercise", "", base_level: 0,titlefmt: strong, fill: rgb("#f4f4f4"))

#set enum(numbering: "1.a.i)")
#show math.equation: eq => math.display[ #eq ]
#let numbered_eq(content) = math.equation(
  block: true,
  numbering: "(1.1.1)",
  content,
)
#let Re=math.op("Re"); #let Im=math.op("Im"); #let Ln=math.op("Ln")
#let pm=math.plus.minus
#let ii=math.upright("i"); #let ramuno=ii
#let ee=math.upright("e"); #let euler=ee; #let eu=euler
#let empty=math.upright("Ø");

= 斯特林公式

#theorem("斯特林公式")[
  $n! tilde sqrt(2 pi n)(n/e)^n$
]

#lemma[
  $sum_(k=1)^n ln k=(n+1/2)ln k - n + O(1)$
]

#proof[

  #image("assets/L3,pic1.jpeg", width: 30%)
  $sum_(k=1)^n ln k < integral_1^(n+1)ln x dif x = (x ln x - x)|_1^(n+1)=(n+1)ln(n+1)-n$

  $&ln k - integral_k^(k+1)ln x dif x\
  =&(x ln x-x)|_k^(k+1)-ln k\
  =&(k+1)ln(k+1)-(k+1)-k ln k + k - ln k\
  =& (k + 1)ln((k+1)/k)-1\
  =&(k+1)ln(1+1/k)-1$

  $ln(1+x)=x-1/2 x^2+1/3 x^3+dots.c$

  $&ln k - integral_k^(k+1)ln x dif x\
  =&(k+1)ln(1/k-1/(2k^2)+1/(3k^2)+dots.c)\
  =&1/(2k)-1/(6k^2)+1/(12k^3)+dots.c$

  $integral_1^(n+1)ln x dif x-sum_(k=1)^n ln k=(n+1)ln(n+1)-n-sum_(k=1)^n (1/(2k)-1/(6k^2)+1/(12k^3)+dots.c)$

  $sum_(k=1)^n ln k=(n+1)ln(n+1)-n-sum_(k=1)^n (1/(2k)-1/(6k^2)+1/(12k^3)+dots.c)$

  又 

  $1/2 sum_(k=1)^n 1/k=1/2 ln n+O(1)$

  所以 

  $sum_(k=1)^n ln k &= (n+1)ln(n+1)-n-1/2 ln n + O(1)\
  &=(n+1)ln(n) dot ln (1+1/n)-n-1/2 ln n + O(1)\
  &=(n+1/2)ln(n)-n+O(1)$
]

应用：

$binom(n,n/2)tilde Theta(2^n/sqrt(n)), quad binom(n,n/2)slash.big 2^n tilde Theta(1/sqrt(n))$ （见第二讲）

$binom(n, n/3)slash.big 2^n=(n!/((n/3)!(2/3 n)!))slash.big 2^n&=(sqrt(2 pi n)(n/e)^n)/(sqrt(2 pi n/3)((n/3) /e)^(n/3)sqrt(2 pi 2/3 n)((2/3 n)/e)^(2/3 n)) slash.big 2^n\
&tilde c/(sqrt(n))dot (3^(n/3)dot (3/2)^(2/3 n))/(2^n)\
&= c/sqrt(n) [(3^(1/3)dot (3/2)^(2/3))/2]^n\
&= c/sqrt(n) ((3 dot 9/4)/8)^(n/3)\
&tilde Theta(1/sqrt(n))dot q^n, quad q<1$

= 可重组合

#problem[
  $m$个球，放到$n$个盒子里
]

#solution[
  #enum[
    球和盒子各不相同：

    #enum[
      允许盒子为空： $n^m$
    ][
      不允许：容斥
    ]

  ][
    球一样，盒子不同：

    设$i$号盒子放$x_i$个球
    $=>$不定方程$cases(sum x_i=m,x_i>=0)$有多少个根

    #highlight[隔板法]

    $ {(x_1,x_2,...,x_n)mid(|)sum_i x_i=m,x_i>=0}$

    令 $y_i=x_i+1$

    则

    ${(y_1,y_2,...,y_n)mid(|)sum_i y_i=m+n,y_i>0}$

    插板，$n-1$个隔板，$m+n-1$个位置$=>binom(n+m-1,n-1)$
  ][
    球不同，盒子相同

    将球看作$m$元集合${1,2,3,...,m}$，切分成$n$个非空子集$A_1 union A_2 union A_3 dots.c A_n$，且$forall i!=j, A_i sect A_j = empty$

    $=>$第二类斯特林数$S_2(m,n)$
  ][
    球和盒子都相同

    $abs({(x_1,x_2,...x_n)mid(|)x_1+dots.c+x_n=m,quad x_1>=x_2>=x_3>=dots.c>=x_n>=0}, size: #200%)$

    $=>$分拆数(partition number): $P(m,n)eq.def m$的$n$分拆 
  ]
]

= 集系 Set System

#problem[

  全集$I={1,2,...,n}(n>2)$

  集系 $cal(A)={S mid(|) S subset.eq I}$ 满足 $forall S_1,S_2 in cal(A), S_1 sect S_2 != empty$，$cal(A)$最多能包含多少个集合？（求 $max abs(cal(A))$）
]

#solution[
  两个大于等于 $ceil(n+1/2)$ 的集合必相交

  $binom(n,n)+binom(n,n-1)+dots.c+binom(n,ceil((n+1)/2))$

  奇数的情况：$2^(n-1)$

  偶数：$(2^n-binom(n,n/2))/2$

  但是$"size"=n/2$的集合也能取，互为补集的两个集合之间取一个，加上$binom(n,n/2)/2$

  故所有情况都是$2^(n-1)$

  另一种构造方式：钦定$1$号元素在所有集合内，则方案数为$2^(n-1)$

  证明方案数不超过$2^(n-1)$

  将所有集合分为两组，第一组内的集合的补集必在第二组中，则不可能取超过$(2^n) /2$个集合，否则同时取了某集合和其补集
]

#definition("反链")[
  $I={1,2,...,n}$

  $cal(A): forall S_1!=S_2 in cal(A), S_1 subset.eq.not S_2, S_2 subset.eq.not S_1$称$cal(A)$是反链，即在以集合包含定义偏序关系的偏序集上两两不可比较的元素构成的集合，我们又称这样的集系为 Sperner 系
]

#problem[
  考虑求$max abs(cal(F))$
]


#solution[
  注意到相同大小的不同集合必不可能相互包含

  取出所有有$k$个元素的集合，$binom(n,k)$

  又$max binom(n,k)= binom(n,floor(n/2))$

  得到 $"ans">=binom(n,floor(n/2))$

  下面证明$"ans"=binom(n,floor(n/2))$

  #lemma("Lubell-Yamamoto-Meshalkin 不等式")[
    对于任意反链$cal(A)subset 2^[n]$有$n!>=sum_(S in cal(A)) abs(S)!(n-abs(S))!$
  ]

  考虑$S in cal(A)$，从$empty$出发，有多少条路径到$S$(每一步增加一个元素)

  #example[
    $empty -> {1} -> {1,2} -> {1,2,4}$
  ]

  方案数：$abs(S)!$

  同理，从$S$出发，到$I$有$(n-|S|)!$条路径

  $=>$对于每个$S$，有$abs(S)!(n-abs(S))!$种路径

  图$G$中共存在$n!$条链，所以$n!>=sum_(S in cal(F)) abs(S)!(n-abs(S))!$

  #theorem("Sperner Theorem, 1928")[
    对反链$cal(F) subset 2^[n], max abs(cal(A))=binom(n, floor(n/2))$
  ]

  要求的就是链的数量，$sum |S!(n-|S|)!<=n!$

  $sum_(s in cal(A)) (|S|!(n-|S|)!)/(n!)<=1$

  $cal(A)/binom(n,floor(n/2))=sum_(s in cal(A)) 1/binom(n,floor(n/2))<= sum_(s in cal(A)) 1/binom(n,|S|)<=1$

  $=>abs(cal(A))<=binom(n,floor(n/2))$

  #problem("思考题")[
    两两相交，且两两互不包含
  ]
  #problem("思考题2")[
    $|S_1 sect S_2|>=3$
  ]
]