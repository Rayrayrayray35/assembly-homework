;==============================================================
; FIB.ASM  --  递归求斐波那契数列第 n 项 (1 <= n <= 100)
; 环境 : MASM 5.10 + LINK 3.64 (DOSBox 0.74-3)
;
; 题目 : F(n) = F(n-1) + F(n-2),  F(0) = 0,  F(1) = 1
;        键盘输入 n, 输出第 n 个斐波那契数, 必须用递归实现.
;
; 两个关键设计:
;   1) 数据用"十进制大数"保存. F(100) = 354224848179261915075 有
;      21 位, 远远超过 16 位(65535)甚至 32 位(4294967295)的范围,
;      所以每个数用 24 个字节存 24 位十进制数字, 低位的字节在前
;      (小端), 相加时逐位相加、满 10 进 1.
;   2) 递归 + 记忆化(memo). 纯双递归的调用次数约为 F(n) 本身,
;      n=100 时是 3.5e20 次, 不可能跑完; 因此把算过的 F(k) 存进
;      memo[k], 再次遇到直接返回. 递归深度仍为 n, 正好用来观察栈.
;
; 栈帧(每层 16 字节):
;       [bp+2] 返回地址      <- CALL 压入
;       [bp+0] 调用者的 bp   <- PUSH BP
;       [bp-2] 局部变量: n
;       [bp-4 .. bp-12]      <- PUSH BX/CX/DX/SI/DI
;==============================================================

        DIGITS  equ 24                  ; 每个大数的十进制位数
        MAXN    equ 100                 ; n 的上限

;--------------------------------------------------------------
; 栈段: 显式开辟 4 KB. 递归深度 101 层 * 16 字节 = 1616 字节,
;       加上主程序与 DOS 中断的开销, 4 KB 足够且留有余量.
;--------------------------------------------------------------
stack   segment stack 'stack'
        dw 2048 dup(0)                  ; 2048 字 = 4096 字节
stack   ends

;--------------------------------------------------------------
; 数据段
;--------------------------------------------------------------
data    segment
memo    db (MAXN+1)*DIGITS dup(0)       ; memo[n] : 24 位十进制数字
valid   db (MAXN+1) dup(0)              ; valid[n]: 1 = 已算过
prompt  db 'n (1-100): $'
resmsg  db 0dh,0ah,'F(n) = $'
errmsg  db 0dh,0ah,'n must be 1..100',0dh,0ah,'$'
crlf    db 0dh,0ah,'$'
inbuf   db 8,0,8 dup(0)                 ; 0AH 缓冲: 最大长度/实际长度/内容
data    ends

;--------------------------------------------------------------
; 代码段
;--------------------------------------------------------------
code    segment
        assume cs:code, ds:data, ss:stack

start:
        mov  ax,data
        mov  ds,ax

        mov  dx,offset prompt           ; 提示
        mov  ah,9
        int  21h

        mov  dx,offset inbuf            ; 0AH: 缓冲输入
        mov  ah,0ah
        int  21h

        call read_n                     ; AX = n
        cmp  ax,1
        jae  ok1
        jmp  bad                        ; n < 1
ok1:
        cmp  ax,MAXN
        jbe  ok2
        jmp  bad                        ; n > 100 (无符号比较)
ok2:
        mov  bx,ax                      ; BX = n

        mov  cx,DIGITS                  ; 计算 &memo[n]
        mul  cx                         ; DX:AX = n * 24
        mov  di,offset memo
        add  di,ax                      ; DI = 目标缓冲区

        mov  ax,bx                      ; AX = n (寄存器传参)
        call fib_rec                    ; 递归计算, 结果写入 [DI]

        mov  dx,offset resmsg
        mov  ah,9
        int  21h

        mov  ax,DIGITS                  ; SI = &memo[n]
        mul  bx
        mov  si,offset memo
        add  si,ax
        call print_big                  ; 输出十进制大数

        mov  dx,offset crlf
        mov  ah,9
        int  21h

        mov  ax,4c00h
        int  21h

bad:
        mov  dx,offset errmsg
        mov  ah,9
        int  21h
        mov  ax,4c00h
        int  21h

;==============================================================
; read_n : 把 inbuf 中的十进制字符串转换成数值
;   入口: inbuf 已由 0AH 功能读入
;   出口: AX = 数值 (非法输入返回 0, 由主程序报错)
;   使用了 BX/CX/DX/SI, 全部保护
;==============================================================
read_n  proc
        push bx
        push cx
        push dx
        push si

        mov  cl,inbuf[1]                ; CL = 实际字符数
        xor  ch,ch
        mov  si,2                       ; 字符从 inbuf+2 开始
        xor  bx,bx                      ; BX = 累加结果
        jcxz rn_done
rn_loop:
        mov  al,inbuf[si]
        cmp  al,13                      ; 回车 = 输入结束(0AH 会把 0Dh 也存进来)
        je   rn_done
        sub  al,'0'
        cmp  al,9
        ja   rn_bad                     ; 不是数字
        xor  ah,ah
        push ax                         ; 保存当前位
        mov  ax,bx                      ; AX = 结果 * 10
        mov  dx,10
        mul  dx
        mov  bx,ax
        pop  ax
        add  bx,ax                      ; 结果 = 结果*10 + 当前位
        inc  si
        loop rn_loop

rn_done:
        mov  ax,bx
        jmp  rn_out
rn_bad:
        xor  ax,ax
rn_out:
        pop  si
        pop  dx
        pop  cx
        pop  bx
        ret
read_n  endp

;==============================================================
; print_big : 输出 SI 指向的 24 位十进制大数(低位在前), 去掉前导零
;   入口: SI = 缓冲区首地址
;==============================================================
print_big proc
        push ax
        push bx
        push cx
        push dx
        push si

        mov  bx,DIGITS-1                ; 从最高位向下找第一个非零位
pb_find:
        cmp  byte ptr [si+bx],0
        jne  pb_print
        dec  bx
        jns  pb_find
        mov  dl,'0'                     ; 全是 0
        mov  ah,2
        int  21h
        jmp  pb_out

pb_print:
        mov  dl,[si+bx]
        add  dl,'0'
        mov  ah,2
        int  21h
        dec  bx
        jns  pb_print                   ; 一直输出到最低位
pb_out:
        pop  si
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
print_big endp

;==============================================================
; fib_rec : 递归求 F(n), 结果写入调用者给出的缓冲区
;
;   入口: AX = n (0..100)             <- 用寄存器传参数
;         DI = 结果缓冲区地址 (&memo[n])
;   出口: [DI..DI+23] = F(n) 的 24 位十进制数字 (低位在前)
;   说明: 所有用到的寄存器都在入口 PUSH、出口 POP, 保证递归
;         返回后调用者的现场不丢.
;==============================================================
fib_rec proc
        push bp
        mov  bp,sp
        sub  sp,2                       ; 局部变量 [bp-2] : n
        push bx
        push cx
        push dx
        push si
        push di

        mov  [bp-2],ax                  ; 保存 n
        mov  bx,ax                      ; BX = n
        cmp  byte ptr valid[bx],0       ; 已经算过?
        je   fr_notdone
        jmp  fr_done                    ; 是 -> 直接返回(记忆化)

fr_notdone:
        cmp  bx,0
        jne  fr_try1
        jmp  fr_mark                    ; F(0) = 0, memo[0] 本来就是 0
fr_try1:
        cmp  bx,1
        jne  fr_rec
        mov  byte ptr [di],1            ; F(1) = 1
        jmp  fr_mark

fr_rec:
;------- 第一层递归: F(n-1) -----------------------------------
        mov  ax,bx
        dec  ax                         ; AX = n-1
        mov  cx,DIGITS
        mul  cx                         ; AX = (n-1)*24
        mov  di,offset memo
        add  di,ax                      ; DI = &memo[n-1]
        mov  ax,bx
        dec  ax
        call fib_rec                    ; 递归! 返回时 memo[n-1] 已填好

;------- 第二层递归: F(n-2) -----------------------------------
        mov  ax,bx
        sub  ax,2                       ; AX = n-2
        mov  cx,DIGITS
        mul  cx
        mov  di,offset memo
        add  di,ax                      ; DI = &memo[n-2]
        mov  ax,bx
        sub  ax,2
        call fib_rec                    ; 递归!

;------- 大数相加: memo[n] = memo[n-1] + memo[n-2] ------------
        mov  ax,bx
        dec  ax
        mov  cx,DIGITS
        mul  cx
        mov  si,offset memo
        add  si,ax                      ; SI = &memo[n-1]

        mov  ax,bx
        sub  ax,2
        mov  cx,DIGITS
        mul  cx
        mov  di,offset memo
        add  di,ax                      ; DI = &memo[n-2]

        mov  ax,bx
        mov  cx,DIGITS
        mul  cx
        mov  bx,offset memo
        add  bx,ax                      ; BX = &memo[n] (结果指针)

        mov  cx,DIGITS                  ; 24 位逐位相加
        xor  ah,ah                      ; AH = 进位
fr_add:
        mov  al,[si]                    ; AL = a[i]
        add  al,[di]                    ;   + b[i]
        add  al,ah                      ;   + 进位
        xor  ah,ah
        cmp  al,10
        jb   fr_store
        sub  al,10                      ; 满 10 进 1
        mov  ah,1
fr_store:
        mov  [bx],al
        inc  si
        inc  di
        inc  bx
        loop fr_add

fr_mark:
        mov  bx,[bp-2]                  ; 取回 n
        mov  byte ptr valid[bx],1       ; 标记 memo[n] 有效
fr_done:
        pop  di
        pop  si
        pop  dx
        pop  cx
        pop  bx
        mov  sp,bp                      ; 释放局部变量
        pop  bp
        ret
fib_rec endp

code    ends
        end start
