#set page("a4")
#set heading(numbering: "1.")
#show heading: it => {
    if (it.level <= 1){
        block(it.body)
    } else if (it.level == 2) {
        block(counter(heading).display() + " " + it.body)
    } else {
        block(it.body)
    }
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

updated: 2025-09-15  

= 第二章-2

== 进制转换   
- 整数的进制转换
整数的十进制转二进制：除2取余法   \
例如： \
45 / 2 = 22 余 1  低位\
22 / 2 = 11 余 0   \
11 / 2 = 5  余 1   \
5  / 2 = 2  余 1   \
2  / 2 = 1  余 0   \
1  / 2 = 0  余 1     高位\
然后将余数倒序排列，得到二进制数：101101


也可以口算：  \
$2^5=32 (100000), 2^4=16, 2^3=8, 2^2=4, 2^1=2, 2^0=1$  \
45 = 32 + 8 + 4 + 1 = $2^5 + 2^3 + 2^2 + 2^0$ = 101101


- 小数的进制转换  
小数十进制转二进制：乘2取整法   \
例如： \
0.625 × 2 = 1.25 取整1  高位\
0.25  × 2 = 0.5  取整0   \
0.5   × 2 = 1.0  取整1  低位\
然后将整数部分依次排列，得到二进制数：0.101

#qt[
  其原理是：\
  $x = 0.a_1 a_2 a_3 ... $ （二进制）
  $= a_1 × 2^{-1} + a_2 × 2^{-2} + a_3 × 2^{-3} + ... $ \
  所以：\
  $2x = a_1.a_2 a_3 ... $ \
  取整数部分 $a_1$，小数部分继续乘2，直到 小数部分为0或达到所需精度。
]

== 补码回顾


== IEEE 754 


#figure(
  image("figures/2-1.png", width: 80%),
  caption: [已知十六进制（hex）,计算十进制小数],
)

#figure(
  image("figures/2-2.png", width: 80%),
  caption: [已知十进制小数，计算IEEE 754 十六进制表示],
)