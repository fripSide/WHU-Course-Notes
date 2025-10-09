#import "my-styles.typ": *
#show link: it => underline(text(fill: blue)[#it.body])


updated: 2025-09-22

= 第三章-2

== 1. 计算机中的数据的运算

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


== 2. 补码运算

== 3. 浮点数运算
