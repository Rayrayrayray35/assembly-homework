;==============================================================
; CFLIB.ASM -- 多文件远调用: 库模块
; 使用独立的 FCODE 段, 与 CFMAIN 的 CSEG 不是同一段.
;==============================================================

        .8086
        include CALMAC.INC

DATA    segment para public 'DATA'
cf2     db 'far-file: inside library',13,10,'$'
DATA    ends

FCODE   segment para public 'CODE'
        assume cs:FCODE, ds:DATA
        public farlib
farlib proc far
        PRINTSTR cf2
        ret                         ; CB (RETF)
farlib endp
FCODE   ends

        end
