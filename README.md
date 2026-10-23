# 汇编语言课程作业

本仓库收录 8086 汇编语言课程的五次作业：环境搭建与 Hello World、ASCII 表、进制转换、求和、九九乘法表。
所有程序均已在 **DOSBox 0.74-3 + MASM 5.10 / LINK 3.64**（C 部分使用 **Turbo C 3.0**）下实测通过。

## 作业一览

| # | 作业内容 | 关键点 | 源码 | 报告 |
|---|----------|--------|------|------|
| 1 | 搭建 16 位汇编环境；用常规方式和 DEBUG 直接写内存两种方式输出 `Hello world!` | `INT 21H` 9 号功能；`LEA` 与 `MOV DX, OFFSET` 的区别；DOSBox 挂载 | [`src/01_hello`](src/01_hello) | [`作业1_报告.docx`](reports/作业1_报告.docx) |
| 2 | 打印小写字母 `a..z`，每行 13 个 | 双重循环；`LOOP` 与 `DEC/JNZ`；`CX` 的保存与恢复；C 语言对照 | [`src/02_ascii`](src/02_ascii) | [`作业2_报告.docx`](reports/作业2_报告.docx) |
| 3 | 1~2 位十六进制数 → 十进制；追加十进制 → 十六进制 | 缓冲输入 `0AH`；`值=值×16+位`；除 10 取余、压栈逆序输出 | [`src/03_hex_dec`](src/03_hex_dec) | [`作业3_报告.docx`](reports/作业3_报告.docx) |
| 4 | 求 `1+2+...+100`，结果分别放寄存器 / 数据段 / 栈；输入 n 求 `1+...+n`；C 实现并反汇编注释 | 16 位运算；`DX:AX ÷ 10`；`09H` 会破坏 `AH` 的坑 | [`src/04_sum`](src/04_sum) | [`作业4_求和_报告.docx`](reports/作业4_求和_报告.docx) |
| 5 | 输出 9×9 乘法表（题目 4：乘法指令和过程调用） | `CALL/RET`；过程内 `PUSH/POP` 保护 `AX/BX/CX/DX`；`MUL`；双重循环；C 反汇编对照 | [`src/05_mul9`](src/05_mul9) | [`作业5_9x9乘法表_报告.docx`](reports/作业5_9x9乘法表_报告.docx) |

## 目录结构

```
.
├─ src/                 汇编与 C 源码（UTF-8）
│  ├─ 01_hello/         hello.asm（LEA）、hello2.asm（OFFSET）
│  ├─ 02_ascii/         ascii1.asm（LOOP）、ascii2.asm（DEC/JNZ）、ascii.c
│  ├─ 03_hex_dec/       exchange.asm
│  ├─ 04_sum/           sum1/2/3.asm、sumn.asm、sum.c、sum_compiled.asm
│  └─ 05_mul9/          mul9.asm、mul9.c、mul9c_annotated.asm（乘法表 + 反汇编）
├─ reports/             Word 报告（提交版）
│  └─ markdown/         同内容 Markdown，便于在线阅读
├─ evidence/            汇编/链接/运行输出（每个作业的实际结果）
├─ docs/                DOSBox 使用说明
└─ scripts/             UTF-8 → GBK/CRLF 转换脚本
```

## 环境

- DOSBox 0.74-3
- MASM 5.10（`MASM.EXE`）、LINK 3.64（`LINK.EXE`）、DEBUG（`DEBUG.EXE`）
- Turbo C 3.0（仅作业 2、4、5 的 C 版本使用）
- 64 位 Windows 不能直接运行 16 位 DOS 程序，必须通过 DOSBox。

DOSBox 中把工作目录挂载为 `C:`：

```dos
mount c d:\myassembly
c:
```

## 构建与运行

仓库中的 `.asm` / `.c` 为 **UTF-8**，方便在 GitHub 上阅读。MASM 5.10 在 DOS 下按 GBK（CP936）工作，且行尾应为 CRLF，因此先用脚本转换到构建目录：

```powershell
# 在仓库根目录执行；输出到 build/gbk
powershell -ExecutionPolicy Bypass -File scripts/utf8-to-gbk.ps1 -Source src -Dest build/gbk
```

然后在 DOSBox 中（以作业 3 为例）：

```dos
mount c <仓库路径>\build\gbk
c:
MASM EXCHANGE.ASM,EXCHANGE.OBJ,EXCHANGE.LST,EXCHANGE.CRF
LINK EXCHANGE.OBJ,EXCHANGE.EXE,EXCHANGE.MAP;
EXCHANGE
```

各作业的完整命令与预期输出见对应报告。

## 运行结果（摘要）

- 作业 1：`Hello world!`（常规方式与 DEBUG 直接写内存均通过）
- 作业 2：

  ```text
  abcdefghijklm
  nopqrstuvwxyz
  ```

- 作业 3：输入 `ff` → 输出 `255`；输入 `255` → 输出 `FF`
- 作业 4：`1+2+...+100 = 5050`；输入 `n=100` → `5050`
- 作业 5：输出 9×9 乘法表，9 行逐行递减，结果与题目样例一致

## 说明

- `reports/` 中的 Word 报告为提交版本；Markdown 版本便于在 GitHub 直接查看。
- 汇编源码中的中文注释在仓库中为 UTF-8；直接交给 MASM 前请按上面的脚本转换为 GBK/CRLF。
- 本仓库不包含 MASM/LINK/DEBUG 等商业工具，请使用课程提供的副本。
