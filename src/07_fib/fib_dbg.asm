;==============================================================
; FIB_DBG.ASM  --  供 DEBUG 单步/断点观察递归栈变化的最小程序
;
; 只保留递归过程本身, 去掉全部输入输出, 这样在 DEBUG 里
; 下断点、单步时不会被 INT 21H 的输入输出干扰.
; n 固定为 5 (F(5)=5), 结果存入 result.
;
; 每层栈帧 8 字节:
;       [bp+2] 返回地址   [bp+0] 旧 bp
;       [bp-2] F(n-1)     [bp-4] 旧 bx
;==============================================================
stack   segment stack 'stack'
        dw 256 dup(0)
stack   ends

data    segment
nval    dw 5
result  dw 0
data    ends

code    segment
        assume cs:code, ds:data, ss:stack

start:
        mov  ax,data
        mov  ds,ax
        mov  ax,nval                    ; AX = 5
        call fib16
        mov  result,ax                  ; result = F(5)
        mov  ax,4c00h
        int  21h

;--------------------------------------------------------------
; fib16 : F(n) = F(n-1) + F(n-2), 入口 AX=n, 出口 AX=F(n)
;--------------------------------------------------------------
fib16   proc
        push bp
        mov  bp,sp
        sub  sp,2                       ; 局部变量 [bp-2]
        push bx
        mov  bx,ax                      ; BX = n

        cmp  bx,2
        jae  f_rec
        mov  ax,bx                      ; F(0)=0, F(1)=1
        jmp  f_exit
f_rec:
        mov  ax,bx
        dec  ax
        call fib16                      ; AX = F(n-1)
        mov  [bp-2],ax
        mov  ax,bx
        sub  ax,2
        call fib16                      ; AX = F(n-2)
        add  ax,[bp-2]
f_exit:
        pop  bx
        mov  sp,bp
        pop  bp
        ret
fib16   endp

code    ends
        end start
