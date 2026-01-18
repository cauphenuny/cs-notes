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

= 素数

证明形为$p=4k+1$的素数有无限个



= 二次剩余