#import "my-styles.typ": *
#show link: it => underline(text(fill: blue)[#it.body])

updated: 2025-09-26

= 第四章-1

risc-v 模拟器：
https://github.com/cnlohr/mini-rv32ima/tree/master

== 1. risc-v指令简介  


== 2. 查看与翻译指令  

翻译单条指令：\
#link("https://luplab.gitlab.io/rvcodecjs/")[Encode/Decode Riscv Instructions]


在线执行多条指令：\
#link("https://www.cs.cornell.edu/courses/cs3410/2019sp/riscv/interpreter/")[利用康奈尔大学的在线模拟器，运行riscv指令]
#figure(
  image("figures/6-1.png", width: 70%),
  caption: [int x = 8191, 对应的汇编（错误情况）],
)


开发我们自己的risc-v模拟器: \
https://github.com/fripSide/my-riscv-emulator  
