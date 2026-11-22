;==============================================================
; CALLDEMO.ASM -- 同一文件内: 段内近调用 + 段间远调用
;
; 运行输出 6 行:
;   1. before near call      -> E8 rel16
;   2. inside near proc
;   3. after near call
;   4. before far call       -> 9A off seg
;   5. inside far proc
;   6. after far call
;
; 机器码见 CALLDEMO.LST / MACHINE_CODE.TXT
;==============================================================

        .8086
        include CALMAC.INC

STACK   segment stack 'STACK'
        dw 64 dup(0)
STACK   ends

DATA    segment para public 'DATA'
m1      db '1: before near call (E8)',13,10,'$'
m2      db '2: inside near proc',13,10,'$'
m3      db '3: after near call',13,10,'$'
m4      db '4: before far call (9A)',13,10,'$'
m5      db '5: inside far proc',13,10,'$'
m6      db '6: after far call',13,10,'$'
DATA    ends

CSEG    segment para public 'CODE'
        assume cs:CSEG, ds:DATA
start:
        mov  ax,DATA
        mov  ds,ax

        PRINTSTR m1
        call nearproc               ; 段内近调用: E8 rel16
        PRINTSTR m3

        PRINTSTR m4
        call far ptr farproc        ; 段间远调用: 9A off seg
        PRINTSTR m6

        mov  ax,4c00h
        int  21h

nearproc proc near
        PRINTSTR m2
        ret                         ; C3
nearproc endp

CSEG    ends

FCODE   segment para public 'CODE'
        assume cs:FCODE, ds:DATA
farproc proc far
        PRINTSTR m5
        ret                         ; CB (RETF)
farproc endp
FCODE   ends

        end start
