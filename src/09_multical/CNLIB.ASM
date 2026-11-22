;==============================================================
; CNLIB.ASM -- 多文件近调用: 库模块
; 与 CNMAIN.ASM 使用同名 CSEG 段, 被 LINK 合并.
;==============================================================

        .8086
        include CALMAC.INC

DATA    segment para public 'DATA'
cn2     db 'near-file: inside library',13,10,'$'
DATA    ends

CSEG    segment para public 'CODE'
        assume cs:CSEG, ds:DATA
        public nearlib
nearlib proc near
        PRINTSTR cn2
        ret                         ; C3
nearlib endp
CSEG    ends

        end
