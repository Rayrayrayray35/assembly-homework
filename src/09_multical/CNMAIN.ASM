;==============================================================
; CNMAIN.ASM -- 多文件近调用: 主模块
; CNLIB.ASM  -- 多文件近调用: 库模块
;
; 两个文件都使用同名 CSEG 段, LINK 合并成一个物理代码段,
; 所以 call nearlib 是 NEAR CALL (E8), 不换 CS.
;==============================================================

        .8086
        include CALMAC.INC

STACK   segment stack 'STACK'
        dw 64 dup(0)
STACK   ends

DATA    segment para public 'DATA'
cn1     db 'near-file: before call',13,10,'$'
cn3     db 'near-file: after call',13,10,'$'
DATA    ends

CSEG    segment para public 'CODE'
        assume cs:CSEG, ds:DATA
        extrn  nearlib:near
start:
        mov  ax,DATA
        mov  ds,ax
        PRINTSTR cn1
        call nearlib                ; 外部近过程: E8 + 链接期重定位
        PRINTSTR cn3
        mov  ax,4c00h
        int  21h
CSEG    ends

        end start
