#import "my-styles.typ": *
#show link: it => {
  underline(emph(text(fill: blue, it)))
}


updated: 2025-09-26 

= 第四章-2

RISCV 基于软件的CPU模拟器实现：
https://github.com/darklife/darkriscv/tree/master


== 1. 需要掌握的常见指令   

#link("https://msyksphinz-self.github.io/riscv-isadoc/")[RISCV Intruction Set]

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


#qt[
指令的功能可以用 寄存器传送语言（register transfer language, RTL）来描述（教材P162 5.1.1节）：

R[r] 表示寄存器r对应的值 \
M[addr] 表示存储单元addr保存的内存值 \
M[PC] PC对应的地址的内存值 \
M[R[r]] 寄存器r对应的值所在的地址的内存值 \
SEXT[imm] 表示对立即数进行符号扩展(左边补充符号位得到32位补码) \
ZEXT[imm] 左边用0扩展到32位 \
$<-$ 将右边的数据保存到左边   
]


下面附上RV32I全部指令的含义： \
https://github.com/jameslzhu/riscv-card \
#link("https://github.com/jameslzhu/riscv-card/releases/download/latest/riscv-card.pdf")[PDF下载链接]

#figure(
  image("figures/7-1.png"),
  caption: [RISC-V card，一页纸RISCV RV32I指令速记],
)

64位指令（本课程不做要求）：\
https://robotics.shanghaitech.edu.cn/courses/ca/19s/notes/riscvcard.pdf

== 2. 调用栈布局与调用约定 (Call Convention)  

=== 1. RISCV函数调用栈布局

- 内存布局（堆、栈、数据代码段、系统内存段）

程序内存布局是由操作系统（或者bootloader）决定的，Linux系统的内存布局如下图：

#figure(
  image("figures/7-2.png", width: 50%),
  caption: [Linux程序运行过程中的内存布局],
)

#qt[
内存布局的划分：

代码段 code/text：只读可执行，存放指令和常量字符串等。编译时确定，地址较低。\

静态数据 static data, 包括:\
- .data：已初始化的全局/静态变量 \
- .bss：未初始化或零初始化的全局/静态变量（启动时清零）\


堆 heap：动态内存，malloc/new 从这里向“高地址”增长（通常由 brk/sbrk 系统调用来实现）。\

栈 stack：函数调用用的临时工作区，通常从高地址向低地址增长。\
system reserved：内核或运行时保留区域（如内核空间、guard pages、VDSO、映射区等）。

#line(length: 100%)

栈顶 top：栈指针（SP）指向的位置称为栈顶。多数架构中，入栈会先移动 SP 再写入数据（向下生长）。

栈与堆中间常留出大片“空白”，二者分别向相反方向增长，避免相撞；出现“栈溢出”时，SP 越界触碰保护页会触发异常（如 SIGSEGV）
]

内存布局的实现原理：系统启动时第一行代码先把对应的代码和数据复制到目标地址位置。具体地址可以在link script中规定。以下是stm32嵌入式设备的简单代码例子，Linux系统的PC和服务器也是同样的原理：

编译阶段的link脚本指定内存段的划分：
```c
/* stm32f4.ld */
ENTRY(Reset_Handler)

/* 片上存储器区域，根据芯片手册修改 */
MEMORY
{
  FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 1024K
  RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 128K
}

/* 提供给启动代码用的符号 */
_estack = ORIGIN(RAM) + LENGTH(RAM);  /* 栈顶 */

SECTIONS
{
  /* 启动向量表放在 Flash 起始 */
  .isr_vector :
  {
    KEEP(*(.isr_vector))     /* 中断向量表 */
  } > FLASH

  /* 代码和只读数据放 Flash */
  .text :
  {
    *(.text*)                 /* 代码 */
    *(.rodata*)               /* 只读常量 */
    . = ALIGN(4);
    _etext = .;               /* Flash 中 text 结束地址，亦是 .data 的加载起点 */
  } > FLASH

  /* 已初始化数据段，运行时在 RAM，加载镜像在 FLASH */
  .data : AT (ADDR(.text) + SIZEOF(.text))
  {
    _sdata = .;               /* RAM 中 .data 起始 */
    *(.data*)
    . = ALIGN(4);
    _edata = .;               /* RAM 中 .data 结束 */
  } > RAM

  /* 未初始化数据段 BSS，运行时在 RAM，需清零 */
  .bss (NOLOAD) :
  {
    _sbss = .;
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
  } > RAM

  /* 可选：把 .init_array/.fini_array 放到 Flash，C 库构造函数 */
  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP(*(SORT(.init_array.*)))
    KEEP(*(.init_array))
    PROVIDE_HIDDEN (__init_array_end = .);
  } > FLASH

  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP(*(SORT(.fini_array.*)))
    KEEP(*(.fini_array))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } > FLASH
}
```

系统启动执行的代码，把代码和数据复制到对应的内存位置：
```c
/* startup.c */
#include <stdint.h>

// 以下变量对应link script中对应的变量，例如：_sdata = .;    
extern uint32_t _estack;

extern uint32_t _etext;   /* Flash:  .text 结束地址 (= .data 的加载地址) */
extern uint32_t _sdata;   /* RAM:    .data 起始 */
extern uint32_t _edata;   /* RAM:    .data 结束 */
extern uint32_t _sbss;    /* RAM:    .bss  起始 */
extern uint32_t _ebss;    /* RAM:    .bss  结束 */

int main(void);

__attribute__((section(".isr_vector")))
void (*const g_pfnVectors[])(void) = {
  (void (*)(void))(&_estack), /* 初始栈指针 */
  Reset_Handler,
  /* 其余中断向量可指向 Default_Handler 或具体 ISR */
};

// 每次开机执行的代码
void Reset_Handler(void)
{
  /* 1) 从 Flash 复制 .data 到 RAM */
  uint32_t *src = &_etext;    /* Flash 中 .data 的镜像起始 */
  uint32_t *dst = &_sdata;
  while (dst < &_edata) {
    *dst++ = *src++;
  }

  /* 2) 清零 .bss */
  for (uint32_t *p = &_sbss; p < &_ebss; ++p) {
    *p = 0;
  }

  /* 3) 可选：调用全局构造函数 */
  extern void __libc_init_array(void);
  __libc_init_array();

  /* 4) 进入主程序 */
  (void)main();

  /* 5) main 返回则停机 */
  while (1) { __asm volatile ("wfi"); }
}
```

启动之后执行的代码：  
```c
/* main.c */
#include <stdint.h>

/* 已初始化的全局变量 -> .data（运行在 RAM，镜像在 Flash） */
uint32_t counter = 123;

/* 未初始化的全局变量 -> .bss（启动时被清零） */
uint8_t rx_buf[256];

int main(void)
{
  counter += 1;     /* 可读写，说明 .data 已正确搬运到 RAM */
  rx_buf[0] = 0x55; /* .bss 已被清零且可写 */
  while (1) { }
}
```


- C程序内存布局

如下图，函数本地局部变量分配在栈上，调用完这个函数之后就会被回收。malloc（C++ new）动态分配的内存在堆上，只要没free就一直存在。
#figure(
  image("figures/7-3.png", width: 50%),
  caption: [C语言不同变量类型所在的内存位置],
)


- 多层调用stack frame结构
每次调用新函数，都会依次开一段新的stack空间（称为stack frame）。内存依次由高地址往低地址减小。

#figure(
  image("figures/7-4.png"),
  caption: [多函数调用时stack frame布局],
)

函数使用寄存器和栈来传递参数。如下图，在O0编译优化级别时，x10-x17前7个参数，也会被保存在栈上（由被调用的函数自己在prologue汇编段中保存）。在O1-O3级别下，只有8/9会被保存在栈上，其他的a0-a7（即x10-x17）不一定会被保存到栈上，可以直接在寄存器中使用。

#figure(
  image("figures/7-5.png", width: 50%),
  caption: [函数参数传递栈布局],
)

#link("https://www.cs.cornell.edu/courses/cs3410/2019sp/schedule/slides/10-calling-notes-bw.pdf")[详见Cornell大学的 CS3410的PPT]

=== 2. RISCV调用约定
#link("https://www2.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CALL.pdf")[RISC-V Call Convention]


除了传递参数之外，caller和callee之间由于共享了寄存器，因此caller需要备份寄存器的值到栈上。其中caller-saved，是调用者负责保存，callee-saved是被调用者负责保存。

#figure(
  image("figures/7-6.png"),
  caption: [RISCV关键寄存器作用],
)

#qt[
其中t0-t6,s0-s11不需要都保存。编译器会将实际用到的进行保存。

例如：\
caller函数中自己用到了t0-t3，那么caller在调用callee时，会自己备份t0-t3到栈上。调用完成之后会恢复t0-t3的值。\
callee函数用到了s0-s5，那么callee在进入时（prologue段汇编中）需要备份s0-s5到栈上,退出时（epilogue段汇编中）从栈上读取值恢复s0-s5。
]