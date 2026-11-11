;==============================================================
; FIB16.ASM  --  16 位字长"朴素双递归"斐波那契 (1 <= n <= 24)
;
; 用途: 配合作业第 6 条"单步跟踪, 观察每次调用/返回时栈空间变化".
;       每层栈帧固定 8 字节, 并且程序会把每次进入/退出时的
;       bp、栈深度打印出来, 便于和 DEBUG 的单步结果对照.
;
; 注意: 16 位无符号数最大 65535, F(24)=46368 可以表示,
;       F(25)=75025 已经溢出, 所以本程序只接受 n <= 24.
;       完整的 1..100 版本见 FIB.ASM (十进制大数).
;
; 栈帧(每层 8 字节):
;       [bp+2] 返回地址
;       [bp+0] 调用者的 bp
;       [bp-2] 局部变量: 保存 F(n-1)
;       [bp-4] 保存的 bx
;==============================================================

        TRACEMAX equ 8                  ; n <= 8 时打印调用轨迹

stack   segment stack 'stack'
        dw 512 dup(0)                   ; 1 KB 栈
stack   ends

data    segment
prompt  db 'n (1-24): $'
resmsg  db 0dh,0ah,'F(n) = $'
errmsg  db 0dh,0ah,'n must be 1..24',0dh,0ah,'$'
crlf    db 0dh,0ah,'$'
inbuf   db 8,0,8 dup(0)

tin     db 0dh,0ah,'[in ] n=$'
tout    db 0dh,0ah,'[out] n=$'
tsp     db ' sp=$'
tdep    db ' depth=$'
tf      db ' F=$'

sptop   dw 0                            ; 程序开始时的 SP, 用来算深度
tmpres  dw 0
traceon db 0                            ; 1 = 打印调用轨迹(只在 n<=8 时打开)
data    ends

code    segment
        assume cs:code, ds:data, ss:stack

start:
        mov  ax,data
        mov  ds,ax
        mov  sptop,sp                   ; 记录栈顶, 后面算深度用

        mov  dx,offset prompt
        mov  ah,9
        int  21h

        mov  dx,offset inbuf
        mov  ah,0ah
        int  21h

        call read_n                     ; AX = n
        cmp  ax,1
        jb   bad
        cmp  ax,24
        ja   bad
        mov  traceon,0                  ; 只有小 n 才打印轨迹, 否则输出会爆炸
        cmp  ax,TRACEMAX
        ja   notrace
        mov  traceon,1
notrace:
        mov  bx,ax

        call fib16                      ; AX = F(n)   <-- 递归入口

        mov  tmpres,ax
        mov  dx,offset resmsg
        mov  ah,9
        int  21h
        mov  ax,tmpres
        call putdec
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
; read_n : 十进制字符串 -> 数值, 出口 AX
;==============================================================
read_n  proc
        push bx
        push cx
        push dx
        push si

        mov  cl,inbuf[1]
        xor  ch,ch
        mov  si,2
        xor  bx,bx
        jcxz rn_done
rn_loop:
        mov  al,inbuf[si]
        cmp  al,13                      ; 回车 = 输入结束
        je   rn_done
        sub  al,'0'
        cmp  al,9
        ja   rn_bad
        xor  ah,ah
        push ax
        mov  ax,bx
        mov  dx,10
        mul  dx
        mov  bx,ax
        pop  ax
        add  bx,ax
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
; putdec : 输出 AX 的十进制值
;==============================================================
putdec  proc
        push ax
        push bx
        push cx
        push dx
        mov  bx,10
        xor  cx,cx
pd_div:
        xor  dx,dx
        div  bx                         ; DX:AX / 10 -> AX 商, DX 余数
        push dx
        inc  cx
        or   ax,ax
        jnz  pd_div
pd_out:
        pop  dx
        add  dl,'0'
        mov  ah,2
        int  21h
        loop pd_out
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
putdec  endp

;==============================================================
; puthex4 : 输出 AX 的 4 位十六进制 (含前导 0), 用来显示栈指针
;==============================================================
puthex4 proc
        push ax
        push bx
        push cx
        push dx
        mov  bx,ax
        mov  cx,4
ph_loop:
        rol  bx,1
        rol  bx,1
        rol  bx,1
        rol  bx,1                       ; 高 4 位移到低 4 位
        mov  dl,bl
        and  dl,0fh
        add  dl,'0'
        cmp  dl,'9'
        jbe  ph_out
        add  dl,7                       ; A..F
ph_out:
        mov  ah,2
        int  21h
        loop ph_loop
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
puthex4 endp

;==============================================================
; trace_in : 打印 "进入" 轨迹
;   入口: BX = n, DX = 本层 bp (栈帧基址)
;==============================================================
trace_in proc
        push ax
        push bx
        push cx
        push dx
        push si
        mov  si,dx                      ; SI = 本层 bp

        mov  dx,offset tin
        mov  ah,9
        int  21h
        mov  ax,bx
        call putdec

        mov  dx,offset tsp
        mov  ah,9
        int  21h
        mov  ax,si
        call puthex4

        mov  dx,offset tdep
        mov  ah,9
        int  21h
        mov  ax,sptop
        sub  ax,si                      ; 深度 = 栈顶 - 本层 bp
        call putdec

        pop  si
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
trace_in endp

;==============================================================
; trace_out : 打印 "返回" 轨迹
;   入口: BX = n, DX = 本层 bp, AX = F(n)
;==============================================================
trace_out proc
        push ax
        push bx
        push cx
        push dx
        push si
        mov  si,dx
        mov  tmpres,ax

        mov  dx,offset tout
        mov  ah,9
        int  21h
        mov  ax,bx
        call putdec

        mov  dx,offset tsp
        mov  ah,9
        int  21h
        mov  ax,si
        add  ax,4                       ; 返回后的 SP = bp+4 (ret 2 + bp 2)
        call puthex4

        mov  dx,offset tdep
        mov  ah,9
        int  21h
        mov  ax,sptop
        sub  ax,si
        sub  ax,4                       ; 按返回后的 SP 计算深度
        call putdec

        mov  dx,offset tf
        mov  ah,9
        int  21h
        mov  ax,tmpres
        call putdec

        pop  si
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
trace_out endp

;==============================================================
; fib16 : 朴素双递归  F(n) = F(n-1) + F(n-2)
;   入口: AX = n        出口: AX = F(n)
;   现场保护: bp/bx 以及调用 trace 时用到的寄存器
;==============================================================
fib16   proc
        push bp
        mov  bp,sp
        sub  sp,2                       ; [bp-2] = F(n-1)
        push bx                         ; 保护调用者的 BX
        mov  bx,ax                      ; BX = n

        cmp  byte ptr traceon,0
        je   f_body
        mov  dx,bp
        call trace_in                   ; 打印进入轨迹

f_body:
        cmp  bx,2
        jae  f_rec
        mov  ax,bx                      ; F(0)=0, F(1)=1
        jmp  f_exit
f_rec:
        mov  ax,bx
        dec  ax
        call fib16                      ; AX = F(n-1)
        mov  [bp-2],ax                  ; 暂存(放栈上, 保证递归安全)

        mov  ax,bx
        sub  ax,2
        call fib16                      ; AX = F(n-2)

        add  ax,[bp-2]                  ; F(n) = F(n-1) + F(n-2)
f_exit:
        cmp  byte ptr traceon,0
        je   f_ret
        mov  dx,bp
        call trace_out                  ; 打印返回轨迹
f_ret:
        pop  bx                         ; 恢复调用者的 BX
        mov  sp,bp                      ; 丢弃局部变量区 [bp-2]
        pop  bp
        ret
fib16   endp

code    ends
        end start
