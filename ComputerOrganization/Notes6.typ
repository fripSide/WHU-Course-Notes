#import "my-styles.typ": *
#show link: it => underline(text(fill: blue)[#it.body])

updated: 2025-09-26

= 第四章-1

== 1. RISC-v指令简介  
RISC-V 是一种基于 精简指令集（RISC） 的开源指令集架构（ISA）。

基础指令数量较少（如 RV32I 仅 40 余条），格式统一，执行效率高。大多数指令可在单时钟周期内完成，流水线效率高。

基于寄存器来进行操作和运算，只有 load 和 store 指令 (例如：lw/sw) 可访问内存，其余指令操作均在寄存器间进行。
```yasm
lw x4, 8(x5)     # 内存加载：x4 = Memory[x5 + 8]
sw x6, 12(x7)    # 内存存储：Memory[x7 + 12] = x6
add x1, x4, x3   # 寄存器操作：x1 = x4 + x3
```

== 2. 寻址方式  
- 立即寻址（Immediate addressing）[riscv原生]\
含义：操作数是指令内的常量，不访存。\
```yasm
ADDI x5, x5, 10 ; x5 = x5 + 10
ANDI x6, x6, 0xFF
LUI x7, 0x12345 ; x7 = 0x12345 << 12
```
- 寄存器寻址（Register addressing）[riscv原生] \
含义：操作数在寄存器中。
```yasm
ADD x3, x1, x2 ; x3 = x1 + x2
XOR x4, x4, x5
MUL x10, x11, x12 ; 需 M 扩展
```

- 直接寻址（Direct/Absolute addressing）[非单指令；组合实现]
含义：指令给出绝对地址 M[addr]。\
RISC‑V 做法：先把绝对地址装入寄存器，再用 0 位移访存。
```yasm
# 例子：读取 M[0x80001000] 到 x8
LUI x7, 0x80001 ; x7 = 0x80001000
LW x8, 0(x7) ; x8 = M32[x7]
```

- 寄存器间接寻址（Register indirect）[riscv原生]
含义：地址在寄存器里，M[Reg]。
```yasm
LB x10, 0(x11) ; x10 = M8[x11]
LD x12, 0(x13) ; x12 = M64[x13]（RV64）
```

- 基址寻址（Base + displacement）[riscv原生]
含义：地址 = 基址寄存器 + 常量位移。
```yasm
LW x5, 16(sp) ; x5 = M32[sp + 16]
SD x6, -24(x8) ; M64[x8 - 24] = x6（RV64）
```

- 变址寻址（Indexed：Base + Index×Scale）[组合实现]
含义：地址 = 基址 + 索引×元素大小（可再加位移）。\
RISC‑V 做法：先在寄存器中算好索引偏移，再访存。
```yasm
# 例子：int32 a[i]，a 在 x10，i 在 x11（RV64）
SLLI x12, x11, 2 ; x12 = i << 2 = i*4
ADD x12, x10, x12 ; x12 = base + offset
LW x13, 0(x12) ; x13 = a[i]
```

- 相对寻址（PC‑relative addressing）[riscv原生（跳转/取地址）]
含义：以 PC 为基址加偏移。
```yasm
# 跳转：
BEQ x1, x2, label ; 若相等，PC = PC + imm
JAL x0, label ; 无条件跳转（x0 丢弃返回地址）

# 取符号地址（位置无关）：
AUIPC x5, %pcrel_hi(sym)
ADDI x5, x5, %pcrel_lo(sym) ; x5 = &sym
LW/LD x6, 0(x5)
```

- 间接寻址（Memory indirect / 二级间接）[组合实现]
含义：指令给出的是一个指针的地址，需“取指针再解引用”（M[M[addr]]）。\
RISC‑V 做法：先取出指针到寄存器，再用该寄存器间接访存。
```yasm
# 例子：addr 常量为指针存放处，读取指针所指向的 32 位值到 x10（RV32）
# 参考教材例4.7，swap函数
LUI x7, upper20(addr)
ADDI x7, x7, lower12(addr) ; x7 = &ptr
LW x8, 0(x7) ; x8 = ptr（从内存取出指针）
LW x10, 0(x8) ; x10 = M32[ptr]
```

== 3. 查看与翻译指令  
在学习过程中，可以通过多个工具来查看riscv汇编指令的实现和执行效果，来加深理解：

- 对着下面指令实现，查看课本的图4.4，图4.8，图4.9， 图4.10， 图4.11，理解每条指令的实现：

#link("https://msyksphinz-self.github.io/riscv-isadoc/")[查看单条指令的实现]
#qt[
  sext/SEXT -> sign extension, 即按照带符号位补码来解析立即数，用符号位从左边来填充将立即数补充到32/64位  

addi rd,rs1,imm   ->   x[rd] = x[rs1] + sext(imm) \
其中：imm会被符号扩展为32位补码，再进行计算  


  zext/ZEXT -> zero extension, 用0在左边来补充立即数到32/64位
]

- 编译和查看代码片段，反编译的指令：\
#link("https://godbolt.org/")[godbolt在线编译器]  
#figure(
  image("figures/6-2.png", width: 90%),
  caption: [godbolt在线编译器看riscv汇编],
)

- 翻译单条指令到二进制：\
#link("https://luplab.gitlab.io/rvcodecjs/")[Encode/Decode Riscv Instructions]


- 在线执行多条指令：\
#link("https://www.cs.cornell.edu/courses/cs3410/2019sp/riscv/interpreter/")[利用康奈尔大学的在线模拟器，运行riscv指令]
#figure(
  image("figures/6-1.png", width: 70%),
  caption: [int x = 8191, 对应的汇编（错误情况）],
)


== 4. 自己实现一个简单的RISC-V模拟器  
开发我们自己的RISC-V模拟器: \
https://github.com/fripSide/my-riscv-emulator  

参考1: 基本实现，还需要自己补充测试用例  \
https://github.com/cnlohr/mini-rv32ima/tree/master


参考2: fsu的lab丰富功能，简化使用  \
https://www.cs.sfu.ca/~ashriram/Courses/CS295//labs/Lab4/index.html