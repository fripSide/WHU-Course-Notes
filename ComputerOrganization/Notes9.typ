#import "my-styles.typ": *
#show link: it => underline(text(fill: blue)[#it.body])

updated: 2025-10-10 \
对应教材5.1-5.2.2


= 第五章-1

RISCV CPU的Verilog FPGA实现：\
https://github.com/riscv-mcu/e203_hbirdv2/tree/master

== 5.1 CPU概述

=== 1. CPU的构成部件  

- 多路选择器 MUX \

#figure(
  image("figures/9-1.png", width: 50%),
  caption: [2路选择器：s为0，y为a，s为1，y值为b],
)

- 状态单元

