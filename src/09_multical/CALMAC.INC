;==============================================================
; CALMAC.INC -- 多模块日历作业的宏定义
;
; MASM 5.10 的宏在汇编时展开，不产生 CALL/RET，因此比过程调用
; 更快，但会增大代码体积。本文件被 CALMAIN/CALDATE/CALDISP
; 三个模块共同包含。
;==============================================================

;--------------------------------------------------------------
; PRINTSTR msg : 输出 DS:DX 指向的 '$' 结尾字符串
;   展开后是 3 条指令，不压栈、不调用过程
;--------------------------------------------------------------
PRINTSTR macro msg
        mov  dx,offset msg
        mov  ah,9
        int  21h
endm

;--------------------------------------------------------------
; NEWLINE : 输出 CR LF
;--------------------------------------------------------------
NEWLINE macro
        push ax
        push dx
        mov  dl,13
        mov  ah,2
        int  21h
        mov  dl,10
        mov  ah,2
        int  21h
        pop  dx
        pop  ax
endm

;--------------------------------------------------------------
; SAVEREGS / RESTOREREGS : 过程入口/出口保护 6 个常用寄存器
;--------------------------------------------------------------
SAVEREGS macro
        push ax
        push bx
        push cx
        push dx
        push si
        push di
endm

RESTOREREGS macro
        pop  di
        pop  si
        pop  dx
        pop  cx
        pop  bx
        pop  ax
endm

;--------------------------------------------------------------
; PROLOG / EPILOG : 近过程的标准栈帧
;   PROLOG 展开为 push bp / mov bp,sp
;   EPILOG 展开为 pop bp / ret
;--------------------------------------------------------------
PROLOG macro
        push bp
        mov  bp,sp
endm

EPILOG macro
        pop  bp
        ret
endm
