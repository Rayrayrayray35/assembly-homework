;==============================================================
; JUMPBAD.ASM -- 故意演示"条件跳转超出 ±127 字节"的汇编错误
;
; 8086 的条件跳转只有 2 字节机器码: 操作码 + 1 字节相对位移,
; 目标地址范围是 -128 ~ +127. 本程序让 JA 跨过 200 个 NOP,
; MASM 5.10 会报: error A2053: Jump out of range by ... byte(s)
;
; 正确改法见 JUMPDEMO.ASM:
;       jbe  skip
;       jmp  near ptr target      ; 近跳转有 16 位位移, 够远
;   skip:
;==============================================================

        .8086
code1 segment para public 'CODE'
        assume cs:code1
start:
        mov  ax,1
        cmp  ax,0
        ja   target                 ; <-- 距离 > 127, 汇编失败
        db   200 dup(90h)
target:
        mov  ax,4c00h
        int  21h
code1 ends
        end start
