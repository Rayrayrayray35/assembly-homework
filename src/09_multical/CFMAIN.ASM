;==============================================================
; CFMAIN.ASM -- 多文件远调用: 主模块
; CFLIB.ASM  -- 多文件远调用: 库模块 (独立 FCODE 段)
;
; 两个模块的代码段名不同, LINK 不会合并, 所以
; call far ptr farlib 是 FAR CALL (9A), 要换 CS.
;==============================================================

        .8086
        include CALMAC.INC

STACK   segment stack 'STACK'
        dw 64 dup(0)
STACK   ends

DATA    segment para public 'DATA'
cf1     db 'far-file: before call',13,10,'$'
cf3     db 'far-file: after call',13,10,'$'
DATA    ends

; 先声明 FCODE 段名, 让 MASM 知道 farlib 在哪个段
FCODE   segment para public 'CODE'
FCODE   ends

extrn  farlib:far

CSEG    segment para public 'CODE'
        assume cs:CSEG, ds:DATA
start:
        mov  ax,DATA
        mov  ds,ax
        PRINTSTR cf1
        call far ptr farlib         ; 外部远过程: 9A off seg
        PRINTSTR cf3
        mov  ax,4c00h
        int  21h
CSEG    ends

        end start
