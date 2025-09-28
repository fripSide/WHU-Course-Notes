#import "my-styles.typ": *
#show link: it => underline(text(fill: blue)[#it.body])

updated: 2025-09-26 

= 第四章-2

risc-v CPU实现：
https://github.com/darklife/darkriscv/tree/master


== 1. 需要掌握的常见指令   

#link("https://msyksphinz-self.github.io/riscv-isadoc/")[Riscv Intruction Set]

可查阅上面链接，来看每条指令是怎么实现的：
#qt[
  addi rd,rs1,imm   ->   x[rd] = x[rs1] + sext(immediate)

  注：sext -> sign extension, 即按照带符号位补码来解析立即数  


  slti rd,rs1,imm -> x[rd] = x[rs1] $<$s sext(immediate) \
  按照有符号数比较


  sltiu rd,rs1,imm -> x[rd] = x[rs1] $<$u sext(immediate) \
  按照无符号数比较

]
解读指令的时候，rd寄存器是指dest（destination，目标操作数）寄存器，rs1/rs2是指src (source，源操作数)寄存器，即：\
rd = rs1 op rs2



下面附上RV32I全部常见指令的含义：




== 2. 寄存器以及别名  


== 3. 调用栈与 call standard   



= 第四章-3