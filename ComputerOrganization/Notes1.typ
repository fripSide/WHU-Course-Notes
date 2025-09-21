#set page("a4")
#set heading(numbering: "1.")

#let font = (
  main: "IBM Plex Serif",
  mono: "IBM Plex Mono",
  cjk: "Noto Serif CJK SC",
)

#show link: underline

2025-09-08 第一次课Notes，对应教材第一章。

= 环境配置  

== windows WSL ubuntu编程环境  
ubuntu是目前最方便的linux版本，windows系统自带的wsl2可以直接安装ubuntu子系统，配合vscode可以方便地进行编程：

- #emph(text(blue)[
	#link("https://blog.csdn.net/steven_ysh/article/details/122148786")[wsl2安装ubuntu,配置vscode]
])

- 更多类似参考：
	- #emph(text(blue)[
		#link("https://zhuanlan.zhihu.com/p/475462241")[win11安装wsl2]
	])

	- #emph(text(blue)[
		#link("https://www.bilibili.com/opus/858519909008670721")[wsl2安装配置]
	])

同时自己可以搜索更多Ubuntu和Linux shell工具的教程：

- #emph(text(blue)[
		#link("https://missing-semester-cn.github.io/")[计算机最基础工具的教程]
	])

== 其他  

- #strong("VPN配置:") 可用clash之类的VPN访问Github和Google  

- 可充分利用AI工具来帮助理解知识点  

= 编程语言  

== Python学习  
python是一门简单、应用广泛的语言，是AI时代的主要编程语言。可以利用空余时间完整学习一遍python:  

- #emph(text(blue)[
		#link("https://www.runoob.com/python/python-install.html")[菜鸟教程Python3]
	])

- #emph(text(blue)[
		#link("https://liaoxuefeng.com/books/python/install/index.html")[廖雪峰Python教程]
	])

== C语言学习  
跟着打几次这些代码：  

- #emph(text(blue)[
		#link("https://www.runoob.com/cprogramming/c-tutorial.html")[菜鸟教程C语言]，在线学习
	])

- #emph(text(blue)[
		#link("https://raw.githubusercontent.com/TIM168/technical_books/master/C%E8%AF%AD%E8%A8%80/The%20C%20Programming%20Language.pdf")[C程序设计语言],	
	]) The C Programming Language, 2nd Edition, Brian W. Kernighan, Dennis M. Ritchie, 是最经典的教材，可以翻一遍

- #emph(text(blue)[
		#link("https://math.ecnu.edu.cn/~jypan/Teaching/ParaComp/main_C.pdf#page=16.42")[华东师大C语言程序设计笔记],
	]) 可以本地编译运行重要代码片段


= 本次课程代码和例子
1. C语言代码, `hello.c`文件：
```c 
#include <stdio.h>
int main() {
		printf("Hello Computer Science!\n");
		return 0;
}
```

2. 输出中间结果
```bash
gcc -E hello.c -o hello.i
gcc -S hello.i -o hello.s

// 编译 
gcc hello.c -o hello.exe

// 运行
./hello.exe
```
