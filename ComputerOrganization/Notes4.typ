#set page("a4")
#set heading(numbering: "1.")
#show heading: it => {
    block(it.body)
}

#let font = (
  main: "IBM Plex Serif",
  mono: "IBM Plex Mono",
  cjk: "Noto Serif CJK SC",
)

#show link: underline

#let qt(body) = {
  block(
    stroke: 0.5pt,
    fill: white,
    inset: 8pt,
    width: 100%,
    [#body]
  )
}

updated: 2025-09-22  

= 第二章-3
== 1. C语言的数据及转换


C语言中的类型提升规则：

- 整数类型提升  
若类型的所有值都能用 int 表示，则提升为 int；\
否则提升为 unsigned int。 
#qt[

]


- 浮点数类型提升  



== 2. 数据对齐与存储  

- 大小端  


- 数据对齐   




= 第三章-1



== 1. 算术逻辑单元实现  



- 标志位 ZF, OF, CF, SF 含义


- 如何在真实程序中查看这些标识位


- 这些标识位的意义  



== 2. 补码的运算


- 补码的真值计算公式
#qt[
对于一个 n 位的补码数（其中$Y_i = 0 或 1$): 
 $ y = -Y_(n-1) × 2^(n-1) + sum_(i=0)^(n-2) (Y_i × 2^i) $

推导过程：

如果y > 0,则符号位$ Y_(n-1)=0$, 
  $ y = sum_(i=0)^(n-2) (Y_i × 2^i) = -Y_(n-1) × 2^(n-1) + sum_(i=0)^(n-2) (Y_i × 2^i) $

如果y < 0,则其真值为:
  $ y = -(2^n - sum_(i=0)^(n-1) (Y_i × 2^i)) = -2^n + Y_(n-1) × 2^(n-1) + sum_(i=0)^(n-2) (Y_i × 2^i) $  
  $ = -Y_(n-1) × 2^(n-1) + sum_(i=0)^(n-2) (Y_i × 2^i) $

]

