#import "my-styles.typ": *

updated: 2025-09-22  

= 第二章-3
== 1. C语言的数据及转换


C语言中的类型提升规则：

多种类型在表达式中混用时，短的类型会被提升为长的类型，有符号被提升为无符号，整数被提升为浮点数。

- 整数类型提升  
若类型的所有值都能用 int 表示，则仍然为 int；\
否则提升为 unsigned int。 char也会提升为unsigned int （即 c语言中unsigned）。
```c
int a = 1;
unsigned b = 2;
if (a > b) {}
if (a + b > 5) {}
// 上面所有计算，int都会被转成unsigned

int a = -1; // 二进制全 1， 0xffff ffff
unsigned b = 1;
if (a > b) { // 这里-f被转成unsigned, 变成一个很大的正整数 0xffff ffff
  // 0xffff ffff > 0x0000 0001
  // true
}

// 这里i = 0, i -1, -1就会溢出
int i = 0;
unsigned len = 5;
while (i - 1 > len) { // true
  // ... 就会一直循环
  --i;
}
```
因此在计算时一定要注意int不要和unsigned int混用。以及unsigned （0u - 1u）, 也会下溢变成很大正整数 4294967295（即 2^32 - 1）


- 浮点数类型提升  
int 和 float/double 计算时，int 会提升为 float/double。\
float和double计算时，float会提升为double。 

由于int和float都是32位，float是采用IEEE 754标准表示的 只有约 24 位二进制有效位，可精确表示的整数范围是 [-2^24, 2^24]，也就是 [-16,777,216, 16,777,216]。因此部分情况下int的精度会丢失。
```c
int i;
if (i== (int)(float)i) {
  // 不一定会成立
  /*
  例如：i = 16,777,217（2^24 + 1）
  (float)i == 16,777,216.0f（被舍入）
  (int)(float)i == 16,777,216 */
}
```

== 2. 数据对齐与存储  

- 大小端  
大端是指，数字的高位（Most Significant Bit, MSB）在前面（和我们人的写法一致）。 \
小端是指，数字的低位（Least Significant Bit, LSB）在前面。  \
目前常用的x86架构是小端，ARM架构可以配置为大端或小端。RISC-V是小端。

判断当前系统是大端还是小端：
```c
// endian.c
#include <stdio.h>
#include <stdint.h>

int main(void) {
    union {
        uint32_t i;
        uint8_t  b[4];
    } u = { .i = 0x01020304 };

    if (u.b[0] == 0x04) {
        puts("Little-endian");
    } else if (u.b[0] == 0x01) {
        puts("Big-endian");
    } else {
        puts("Unknown");
    }
    return 0;
}
```
或者也可以用指针：
```c
#include <stdio.h>
#include <stdint.h>

int main(void) {
    uint32_t x = 0x01020304;
    unsigned char *p = (unsigned char*)&x;
    // p 指向 x 的第一个字节  
    if (p[0] == 0x04)
        puts("Little-endian");
    else if (p[0] == 0x01)
        puts("Big-endian");
    else
        puts("Unknown");

    return 0;
}
```
编译和运行：
```bash
gcc -o endian.exe endian.c
./endian.exe
```

- 数据对齐   
数据对齐是指数据在内存中按其类型大小的整数倍地址存放。\
例如，int类型（4字节）变量的地址必须是4的倍数，short类型（2字节）变量的地址必须是2的倍数, char的起始地址可以不用对齐。

数据对齐可以提高内存访问效率，因为大多数处理器在对齐地址访问数据时速度更快。

```c
struct A {
    char c;      // 1 byte
    // 3 bytes padding
    int i;       // 4 bytes
    short s;     // 2 bytes
    // 2 bytes padding
};
// sizeof(struct A) == 12

struct B {
    char c1;     // 1 byte
    char c2;     // 1 byte
    // 2 bytes padding
    int i;       // 4 bytes
    short s;     // 2 bytes
    // 2 bytes padding
};
// sizeof(struct B) == 12

struct C {
    double d;    // 8 bytes
    char c;      // 1 byte
    // 7 bytes padding
};
// sizeof(struct C) == 16

// 由于前面是4byte，所以不需要填充
struct D {
    char c;      // 1 byte
    char c2;     // 1 byte
    short s;     // 2 bytes
    int i;       // 4 bytes
};
// sizeof(struct D) == 8

struct E {
    char c;      // 1 byte
};
// sizeof(struct E) == 1

struct F {
    char c;      // 1 byte
    char c2;     // 1 byte
};
// sizeof(struct F) == 2
```

验证代码：
```c
// struct_size.c 文件
#include <stdio.h>
#include <stdint.h>

struct D {
    char c;      // 1 byte
    char c2;     // 1 byte
    short s;     // 2 bytes
    int i;       // 4 bytes
};

int main(void) {
    printf("sizeof(struct D) = %ld\n", sizeof(struct D));
    return 0;
}
// 运行命令
// gcc -o struct_size.exe struct_size.c
// ./struct_size.exe
```


= 第三章-1

== 1. 算术逻辑单元实现  

- C语言中的位运算
#qt[
! 逻辑非：真变假、假变真；常用 !!x 把值转布尔。 

& 按位与：两位都为1才为1；常用于清位、检测掩码位。

| 按位或：任一位为1则为1；常用于置位。

^ 按位异或：相同为0，不同为1；可用于翻转指定位、无进位加法。

$~$ 按位取反：0变1、1变0。

<< 左移：整体左移n位，右侧补0；约等于乘以2^n（注意溢出）。

>> 右移：整体右移n位，左侧补符号位。
]

- 标志位 ZF, OF, CF, SF 含义
C语言在进行算术运算时，CPU会根据运算结果设置一些标志位（Flags），这些标志位可以用来判断运算结果的性质。常见的标志位包括：
#qt[
ZF (Zero Flag): 当运算结果为零时，ZF被置位（设为1）；否则清零（设为0）。常用于条件跳转指令中，判断结果是否为零。

OF (Overflow Flag): 当有符号数运算结果超出其表示范围时，OF被置位；否则清零。常用于检测有符号数的溢出情况。

CF (Carry Flag): 当无符号数运算结果超出其表示范围时，CF被置位；否则清零。常用于检测无符号数的溢出情况，特别是在多字节或多字的加法和减法中。

SF (Sign Flag): 当运算结果为负数时，SF被置位；否则清零。常用于判断结果的符号，特别是在有符号数的比较中。
]

- 如何在程序代码中查看这些标识位  
可以通过汇编语言指令来查看这些标识位的状态，例如使用 `FLAGS` 寄存器。
```c
#include <stdio.h>
#include <stdint.h>

// PUSHFQ 是 x86-64 架构中的一条指令，用于把当前的 RFLAGS（64 位标志寄存器）压入栈中
// popq = r, 是把栈顶的值弹出到 r 所在的寄存器中
static inline uint64_t read_rflags_asm(void) {
    uint64_t r;
#if defined(__x86_64__)
    __asm__ volatile (
        "pushfq\n\t"
        "popq %0"
        : "=r"(r)
        :
        : "memory"
    );
#else
    uint32_t e;
    __asm__ volatile (
        "pushfd\n\t"
        "pop %0"
        : "=r"(e)
        :
        : "memory"
    );
    r = e;
#endif
    return r;
}

static inline void print_flags(uint64_t rf, const char* note) {
    int CF = (rf >> 0) & 1;
    int PF = (rf >> 2) & 1;
    int AF = (rf >> 4) & 1;
    int ZF = (rf >> 6) & 1;
    int SF = (rf >> 7) & 1;
    int OF = (rf >> 11) & 1;
    printf("%s CF=%d PF=%d AF=%d ZF=%d SF=%d OF=%d (RFLAGS=0x%llx)\n",
           note, CF, PF, AF, ZF, SF, OF, (unsigned long long)rf);
}

int main(void) {
    // c = 0xFFFFFFFF + 1 = 0, 产生进位，影响CF
    volatile unsigned a = 0xFFFFFFFFu, b = 1;
    volatile unsigned c = a + b; // 影响标志

    uint64_t rf = read_rflags_asm();
    print_flags(rf, "After a+b:");

    volatile int x = 0x7FFFFFFF, y = 1, z = x + y; // 有符号溢出
    rf = read_rflags_asm();
    print_flags(rf, "After x+y:");

    return 0;
}
```
结果为：
```bash
After a+b: CF=1 PF=1 AF=1 ZF=1 SF=0 OF=0 (RFLAGS=0x257)
After x+y: CF=0 PF=1 AF=1 ZF=0 SF=1 OF=1 (RFLAGS=0xa96)
```

== 2. 加法器的实现  
- 补码的表示与运算
#qt[
补码的表示：对于一个 n 位的二进制数，其补码表示为
- 正数的补码与其原码相同。    
- 负数的补码为其绝对值的原码按位取反后加1。
补码的范围：对于 n 位补码，表示的整数范围为 $[-2^(n-1), 2^(n-1)-1]$。
补码的优点：补码使得加法和减法可以统一处理，简化了硬件设计。\
补码的加法：两个补码数相加时，直接进行二进制加法，忽略最高位的进位。\
补码的减法：减法    
可以通过加上被减数的补码来实现，即 $A - B = A + (-B)$。
] 


- 加法器的实现  
A,B都为1位二进制（0 或 1），则 A + B 可表示为：\
sum(A+B) = (A XOR B) XOR Cin 

进位：\
Cout = carry(A+B) = (A AND B) OR ((A XOR B) AND Cin)

电路如下：
#figure(
  image("figures/4-1.png", width: 40%),
  caption: [1位加法器实现电路],
)

- 多级加法器  
多位二进制数的加法可以通过级联多个1位加法器来实现。\
例如，4位二进制数 $a_3a_2a_1a_0$ 和 $b_3b_2b_1b_0$ 的加法可以通过4个1位加法器级联实现。\
每个加法器的进位输出连接到下一个加法器的进位输入。
#figure(
  image("figures/4-2.png", width: 60%),
  caption: [4位加法器实现电路],
)

- 溢出检测  
对于有符号数的加法，如果两个正数相加得到负数，或者两个负数相加得到正数，则发生溢出。
溢出的检测可以通过检查最高位的进位和次高位的进位是否不同来实现。
#qt[
8 位正溢出例子（正 + 正 → 负）:

A = 0111 1111 (127) \
B = 0000 0001 (1)\

扩展（符号复制）：\
A_ext = 0 0111 1111，\
B_ext = 0 0000 0001

9 位求和：\
S_ext = 1 0000 0000

最高两位：
S_ext[8]=1，
S_ext[7]=0 → 异或=1 → 溢出

#line(length: 100%)

8 位负溢出例子（负 + 负 → 正）：\

A = 1000 0000 (-128) \
B = 1000 0000 (-128) \

扩展：\
A_ext = 1 1000 0000，\
B_ext = 1 1000 0000

9 位求和：\
S_ext = 1 0000 0000

最高两位：1 和 0 → 异或=1 → 溢出 \
注：数学结果 -256 超出 8 位补码范围
]

