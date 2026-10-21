# DOSBox 使用说明（速查）

> 本机环境：DOSBox 0.74-3 + MASM/LINK/DEBUG，工作目录 `D:\myassembly`。
> 已把 `mount c d:\myassembly` + `c:` 写进配置文件，**双击 DOSBox 即进入 C:\**。

## 一、环境位置
- DOSBox：开始菜单 **DOSBox 0.74-3**（或 `C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe`）
- 工作目录：`D:\myassembly`（含 MASM.EXE / LINK.EXE / DEBUG.EXE / 示例 hello.asm）
- 配置：`C:\Users\Ray\AppData\Local\DOSBox\dosbox-0.74-3.conf` 的 `[autoexec]` 段：
  ```
  mount c d:\myassembly
  c:
  SET PATH=Z:\;C:\TURBOC3\BIN
  ```

## 二、常用操作
- DOS 命令：`DIR` 列目录、`CD` 换目录、`CLS` 清屏、`TYPE 文件` 看内容、`EXIT` 退出
- 热键：`Alt+Enter` 全屏、`Ctrl+F10` 释放鼠标
- 退出：关窗口 或 敲 `EXIT`

## 三、运行一段汇编源码：4 步
前提：源程序必须是 16 位 DOS 程序（段定义 + 用 `INT 21H,AH=4CH` 返回 DOS）。

**0) 写源码**：用记事本/VS Code 写 `xxx.asm`，存到 `D:\myassembly`；
  文件名用短英文（8.3 规则，别用中文名），编码存 **ANSI**（不要 UTF-8 BOM）。

**1) 汇编**  `.asm → .obj`
```
MASM hello.asm;
```
`;` = 后面所有提示（目标/列表/交叉引用文件名）全取默认值。
想同时要列表文件：`MASM hello.asm,hello.obj,hello.lst;`

**2) 连接**  `.obj → .exe`
```
LINK hello.obj;
```

**3) 运行**
```
HELLO
```

改源码后重复 1→2→3。

## 四、hello.asm 实操
```
dir
masm hello.asm,hello.obj,hello.lst,hello.crf;
link hello.obj,hello.exe,hello.map;
hello
```
输出：`Hello world!`
产物：`HELLO.OBJ / HELLO.EXE / HELLO.LST / HELLO.CRF / HELLO.MAP`。

## 五、常见报错
| 现象 | 原因 / 解决 |
|---|---|
| Unable to open input file 'X.ASM' | 文件不在当前目录 / 名字不对（先 DIR；别用中文名、别超 8 字符） |
| 乱码 / 报错一堆 | 源文件编码不对 → 另存为 ANSI；中文注释尽量少 |
| Program too big to fit in memory | 内存模型太大 → 用 `.model small` |
| 双击 .EXE 打不开 | 16 位 DOS 程序不能在 64 位 Windows 直接跑 → 必须经 DOSBox |
| 跑一下秒回命令行 | 正常（执行完并返回 DOS，结果在屏幕上） |

## 六、进阶
- 调试：`DEBUG hello.exe` → 进去后 `U` 反汇编、`T` 单步、`G` 运行、`Q` 退出。
- 生成 .COM：tiny 模型汇编链接后 `EXE2BIN hello.exe hello.com`。
- 换工作目录：改 `dosbox-0.74-3.conf` 的 `[autoexec]`（如再加 `mount d e:\data`）。
