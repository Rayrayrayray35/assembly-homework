;==============================================================
; CALLTRACE.ASM -- 单步观察 CALL/RET 前后的 CS、IP、SP 和栈内容
;
; 输出三组状态:
;   near before / near entry / near after
;   far  before / far  entry / far  after
;
; near entry 时 [SP] 是返回 IP, CS 不变;
; far  entry 时 [SP] 是返回 IP, [SP+2] 是返回 CS, CS 已切换.
;
; 说明: 打印的 IP 是"调用点标签的偏移", 方便对照;
;       栈里的 [SP]/[SP+2] 才是 CPU 实际压入的返回地址.
;==============================================================

        .8086
        include CALMAC.INC

DATA    segment para public 'DATA'
l_near_before db 'near before: $'
l_near_entry  db 'near entry : $'
l_near_after  db 'near after : $'
l_far_before  db 'far  before: $'
l_far_entry   db 'far  entry : $'
l_far_after   db 'far  after : $'

s_cs    db ' CS=$'
s_ip    db ' IP=$'
s_sp    db ' SP=$'
s_st0   db ' [SP]=$'
s_st2   db ' [SP+2]=$'
crlf    db 13,10,'$'
hexbuf  db 5 dup('$')
savedip dw 0
savedsp dw 0
stkptr  dw 0
DATA    ends

STACK   segment stack 'STACK'
        dw 256 dup(0)
STACK   ends

CSEG    segment para public 'CODE'
        assume cs:CSEG, ds:DATA, ss:STACK

start:
        mov  ax,DATA
        mov  ds,ax

;---------------- 近调用前 ----------------
n_before:
        mov  bx,sp
        mov  dx,offset l_near_before
        mov  ax,offset n_before
        call showstate

        call nearproc               ; E8

;---------------- 近调用后 ----------------
n_after:
        mov  bx,sp
        mov  dx,offset l_near_after
        mov  ax,offset n_after
        call showstate

;---------------- 远调用前 ----------------
f_before:
        mov  bx,sp
        mov  dx,offset l_far_before
        mov  ax,offset f_before
        call showstate

        call far ptr farproc        ; 9A

;---------------- 远调用后 ----------------
f_after:
        mov  bx,sp
        mov  dx,offset l_far_after
        mov  ax,offset f_after
        call showstate

        mov  ax,4c00h
        int  21h

;--------------------------------------------------------------
; nearproc : 近过程, 入口 [SP]=返回 IP
;--------------------------------------------------------------
nearproc proc near
        mov  bx,sp
        mov  dx,offset l_near_entry
        mov  ax,offset nearproc
        call showstate

        mov  bx,sp
        call showstack2
        ret                         ; C3
nearproc endp

;--------------------------------------------------------------
; showstate : DX=标签, AX=IP, BX=SP
;--------------------------------------------------------------
showstate proc near
        push ax
        push bx
        push cx
        push dx
        push si

        mov  savedsp,bx             ; 先存到内存, 防止 INT 21H 破坏寄存器
        mov  savedip,ax

        mov  ah,9
        int  21h                    ; 打印 DX 指向的标签

        mov  dx,offset s_cs
        mov  ah,9
        int  21h
        mov  ax,cs
        call puthex16

        mov  dx,offset s_ip
        mov  ah,9
        int  21h
        mov  ax,savedip
        call puthex16

        mov  dx,offset s_sp
        mov  ah,9
        int  21h
        mov  ax,savedsp
        call puthex16

        mov  dx,offset crlf
        mov  ah,9
        int  21h

        pop  si
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
showstate endp

;--------------------------------------------------------------
; showstack2 : BX=栈指针, 打印 [BX] 和 [BX+2]
;--------------------------------------------------------------
showstack2 proc near
        push ax
        push bx
        push dx
        push si

        push bp
        mov  bp,bx

        mov  dx,offset s_st0
        mov  ah,9
        int  21h
        mov  ax,[bp]
        call puthex16

        mov  dx,offset s_st2
        mov  ah,9
        int  21h
        mov  ax,[bp+2]
        call puthex16

        mov  dx,offset crlf
        mov  ah,9
        int  21h

        pop  bp
        pop  si
        pop  dx
        pop  bx
        pop  ax
        ret
showstack2 endp

;--------------------------------------------------------------
; puthex16 : AX -> 4 位十六进制
;--------------------------------------------------------------
puthex16 proc near
        push ax
        push bx
        push cx
        push dx
        push si

        mov  bx,ax
        mov  si,offset hexbuf
        mov  cx,4
ph_loop:
        rol  bx,1
        rol  bx,1
        rol  bx,1
        rol  bx,1
        mov  al,bl
        and  al,0Fh
        cmp  al,9
        jbe  ph_dec
        add  al,7
ph_dec:
        add  al,'0'
        mov  [si],al
        inc  si
        loop ph_loop

        mov  byte ptr [si],'$'
        mov  dx,offset hexbuf
        mov  ah,9
        int  21h

        pop  si
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
puthex16 endp

CSEG    ends

FCODE   segment para public 'CODE'
        assume cs:FCODE, ds:DATA, ss:STACK

;--------------------------------------------------------------
; farproc : 远过程, 入口 [SP]=返回 IP, [SP+2]=返回 CS
;
; 注意: 下面的 f_showstate/f_showstack2/f_puthex16 是 CSEG 里
; 同名过程的副本. 因为 FCODE 与 CSEG 是不同段, 不能近调用
; CSEG 里的过程; 要么远调用(会多压 CS:IP, 干扰栈观察), 要么
; 在本段复制一份. 这里选择复制, 保证观察到的 SP 就是 farproc
; 刚进入时的 SP.
;--------------------------------------------------------------
farproc proc far
        mov  bx,sp
        mov  dx,offset l_far_entry
        mov  ax,offset farproc
        call f_showstate

        mov  bx,sp
        call f_showstack2
        ret                         ; CB (RETF)
farproc endp

;--------------------------------------------------------------
; f_showstate : DX=标签, AX=IP, BX=SP (FCODE 版)
;--------------------------------------------------------------
f_showstate proc near
        push ax
        push bx
        push cx
        push dx
        push si

        mov  savedsp,bx             ; 先存到内存, 防止 INT 21H 破坏寄存器
        mov  savedip,ax

        mov  ah,9
        int  21h

        mov  dx,offset s_cs
        mov  ah,9
        int  21h
        mov  ax,cs
        call f_puthex16

        mov  dx,offset s_ip
        mov  ah,9
        int  21h
        mov  ax,savedip
        call f_puthex16

        mov  dx,offset s_sp
        mov  ah,9
        int  21h
        mov  ax,savedsp
        call f_puthex16

        mov  dx,offset crlf
        mov  ah,9
        int  21h

        pop  si
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
f_showstate endp

;--------------------------------------------------------------
; f_showstack2 : BX=栈指针, 打印 [BX] 和 [BX+2] (FCODE 版)
;--------------------------------------------------------------
f_showstack2 proc near
        push ax
        push bx
        push dx
        push si

        push bp
        mov  bp,bx

        mov  dx,offset s_st0
        mov  ah,9
        int  21h
        mov  ax,[bp]
        call f_puthex16

        mov  dx,offset s_st2
        mov  ah,9
        int  21h
        mov  ax,[bp+2]
        call f_puthex16

        mov  dx,offset crlf
        mov  ah,9
        int  21h

        pop  bp
        pop  si
        pop  dx
        pop  bx
        pop  ax
        ret
f_showstack2 endp

;--------------------------------------------------------------
; f_puthex16 : AX -> 4 位十六进制 (FCODE 版)
;--------------------------------------------------------------
f_puthex16 proc near
        push ax
        push bx
        push cx
        push dx
        push si

        mov  bx,ax
        mov  si,offset hexbuf
        mov  cx,4
f_ph_loop:
        rol  bx,1
        rol  bx,1
        rol  bx,1
        rol  bx,1
        mov  al,bl
        and  al,0Fh
        cmp  al,9
        jbe  f_ph_dec
        add  al,7
f_ph_dec:
        add  al,'0'
        mov  [si],al
        inc  si
        loop f_ph_loop

        mov  byte ptr [si],'$'
        mov  dx,offset hexbuf
        mov  ah,9
        int  21h

        pop  si
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
f_puthex16 endp

FCODE   ends

        end start
