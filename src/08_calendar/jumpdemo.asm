;==============================================================
; JUMPDEMO.ASM -- 短跳转 / 近跳转 / 远调用 / 远跳转 的机器码演示
;
; 运行后依次输出 5 行, 对应:
;   1. JMP SHORT   -> EB rel8        (段内, 1 字节位移)
;   2. JMP NEAR    -> E9 rel16       (段内, 2 字节位移)
;   3. CALL FAR    -> 9A off seg     (段间, 压 CS:IP)
;   4. JMP FAR     -> EA off seg     (段间, 直接换 CS:IP)
;   5. 已进入 CODE2, 退出
;
; 机器码可用 MASM 生成的 .LST 文件逐条核对.
;==============================================================

        .8086

stackseg segment stack 'STACK'
        dw 64 dup(0)
stackseg ends

dataseg segment para public 'DATA'
m1      db '1: short jump (EB rel8)',13,10,'$'
m2      db '2: near jump  (E9 rel16)',13,10,'$'
m3      db '3: far call   (9A off seg)',13,10,'$'
m4      db '4: far jump   (EA off seg)',13,10,'$'
m5      db '5: now in CODE2, exit',13,10,'$'
dataseg ends

code1 segment para public 'CODE'
        assume cs:code1, ds:dataseg, ss:stackseg
start:
        mov  ax,dataseg
        mov  ds,ax

        mov  dx,offset m1
        mov  ah,9
        int  21h

        jmp  short sh1              ; EB xx
        db   20 dup(90h)            ; 填充, 让短跳转位移看得见
sh1:
        mov  dx,offset m2
        mov  ah,9
        int  21h

        jmp  near ptr nr1           ; E9 xx xx (跨过 200 字节)
        db   200 dup(90h)
nr1:
        call far ptr proc2          ; 9A off seg
        mov  dx,offset m4
        mov  ah,9
        int  21h

        jmp  far ptr far_entry      ; EA off seg (不返回)
code1 ends

code2 segment para public 'CODE'
        assume cs:code2, ds:dataseg, ss:stackseg
proc2   proc far
        mov  dx,offset m3
        mov  ah,9
        int  21h
        ret                         ; CB
proc2   endp

far_entry:
        mov  dx,offset m5
        mov  ah,9
        int  21h
        mov  ax,4c00h
        int  21h
code2 ends

        end start
