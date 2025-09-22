#set page("a4")
#set heading(numbering: "1.")
#show heading: it => {
    if (it.level <= 1){
        block(it.body)
    } else {
        block(counter(heading).display() + " " + it.body)
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

updated: 2025-09-12  

= 第一章

== ISA架构  
可以问大模型来理解这些概念： \
#quote()[
*ISA（指令集架构）*是处理器硬件和软件之间的接口，定义了处理器支持的指令、数据类型、寄存器、寻址模式和存储模型（即内存地址空间、数据布局对齐方式等），使软件能够与硬件交互。
]

== 时钟周期与执行时间  
时钟周期 (Clock Cycle)：时钟周期是处理器执行指令的基本时间单位（tick，可以类比为时钟指针走一格）。由处理器的时钟频率决定。一个时钟周期代表处理器时钟信号从高到低或从低到高的变化    
- 时钟频率 (Clock Frequency)：每秒的时钟周期数，通常以赫兹 (Hz) 为单位，较高的时钟频率意味着处理器运行更快。例如，3 GHz 的处理器每秒有 $3×10^9$个时钟周期  
- 时钟周期时间 (Clock Cycle Time)：每个时钟周期的持续时间，计算公式为：  
  - Clock Cycle Time = 1 / Clock Frequency,  时钟周期时间 = 1 / 时钟频率
  - 例如，3 GHz 的处理器的时钟周期时间为：  
    - Clock Cycle Time = 1 / (3 × 10^9) ≈ 0.333 纳秒 (ns)  
-  CPI (Cycles Per Instruction): 每条指令平均需要的时钟周期数。不同类型的指令可能需要不同数量的时钟周期来执行，因此CPI通常是指程序或者整个计算机的*平均*每条指令需要的周期数。CPI 是衡量处理器效率的重要指标，较低的 CPI 通常表示更高效的处理器设计。
- 指令周期 (Instruction Cycle)：指令周期是处理器执行一条指令所需的完整过程，通常包括取指 (Fetch)、译码 (Decode)、执行 (Execute)、访存 (Memory Access) 和写回 (Write Back) 等阶段。一个指令周期可能需要多个时钟周期来完成，具体取决于指令的复杂性和处理器的设计。  
  - CPI = 总指令数/总时钟周期数

计算公式：
- 执行时间 = 指令数×CPI×时钟周期时间
- 执行时间 = 指令数×CPI/时钟频率
  - 假设一个程序包含 10 亿条指令，处理器的时钟频率为 2 GHz，平均 CPI 为 2，则执行时间为：
    执行时间 = (指令数×CPI) / 时钟频率 = $frac(10^9 × 2, 2 × 10^9)$=1秒



= 第二章-1
 
== 查看C语言数据类型  
查看各个字段的长度：  
```c
// type_sizes.c
#include <stdio.h>

int main() {
    printf("char: %zu bytes\n", sizeof(char));
    printf("short: %zu bytes\n", sizeof(short));    
    printf("int: %zu bytes\n", sizeof(int));
    printf("long: %zu bytes\n", sizeof(long));
    printf("long long: %zu bytes\n", sizeof(long long));
    printf("float: %zu bytes\n", sizeof(float));
    printf("double: %zu bytes\n", sizeof(double));
    printf("long double: %zu bytes\n", sizeof(long double));
    return 0;
}
```
编译运行：
```bash
gcc type_sizes.c -o type_sizes.exe
./type_sizes.exe
char: 1 bytes
short: 2 bytes
int: 4 bytes
long: 8 bytes
long long: 8 bytes
float: 4 bytes
double: 8 bytes
long double: 16 bytes
```


查看数值的表示：
```c
// int_mem.c
#include <stdio.h>

int main(){
  int var0 = 0;
  int var1 = -1;
  int var2 = -2;
  int var3 = 3;
  float f1 = 0.1;
  double d1 = 0.1;
  printf("var0 = %d, var1 = %d, var2 = %d, var3 = %d\n", var0, var1, var2, var3);
  printf("f1 = %.20f d1 = %.20f\n", f1, d1);
  return 0;
}
```

编译并调试：
```bash
gcc -g int_mem.c -o int_mem.exe
gdb int_mem.exe
(gdb) break 9
(gdb) run
(gdb) print var0 
// 打印从var0开始的8 * 32Byte (8个Int范围) 的内存值     
(gdb) x/8wx &var0
0x7fffffffdc64: 0x00000000      0xffffffff      0xfffffffe      0x00000003
0x7fffffffdc74: 0x3dcccccd      0x9999999a      0x3fb99999      0xffffdd20
```

能看出int在内存中以补码的形式存储， -1 是0xffffffff， -2 是 0xfffffffe。  \
0.1的浮点数表示为：0x3dcccccd。



== 原码、反码、补码  

- 原码
直接用二进制位表示数值和符号，最高位为符号位（0表示正数，1表示负数），其余位表示数值的绝对值。例如，+5的原码是00000101，-5的原码是10000101。


由于原码不方便实现计算电路（减法存在借位），因此逐步提出了反码和补码。反码的存在是为了简化计算机对负数的表示和运算（让正数加负数不需要计算减法），并为后来的补码设计打下基础。尽管最终计算机使用的是补码，但反码在历史发展中起到了重要的过渡作用。

- 反码
正数的反码和原码相同。\
负数的反码是将正数的所有位逐位取反（符号位除外）。

#qt[
正零的反码表示：所有位为 0，和原码一致，即 00000000。\
负零的反码表示：符号位为 1，其余位为 0，即原码为 10000000，反码11111111。
]

由于0存在两种表示方法，所以计算仍然很复杂。反码刚出来就被补码取代。  

- 补码  
#qt[
正数补码：正数。 \
负数补码：2^n - 负数绝对值。
]

为什么用补码计算减法时，能直接相加？\
#qt[
  补码(-B) = $2^n - B$ \
  A  - B = A + (-B)  \
  补码（A） + 补码（-B） $= A + (2^n - B) = A - B + 2 ^ n = A - B $
]

在补码表示中，负零和正零统一表示为一个值（即 0000 0000），从而避免了反码中正零和负零的冗余问题。

#qt[
  补码(0) = 原码（0） = 0 \
  补码(-0) = $2^n - 0 = 0$
]


- 总结
原码 → 表示简单，但运算复杂 \
反码 → 统一了加法逻辑，但存在“负0”问题 \
补码 → 在反码的基础上消除“负0”，成为现代计算机的标准 