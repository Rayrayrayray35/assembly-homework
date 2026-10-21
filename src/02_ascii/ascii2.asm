;===========================================================
;  ASCII2.ASM -- 打印小写字母 a..z，每行 13 个（DEC/JNZ 版）
;  环境: MASM 5.10 + LINK，16 位 DOS (.EXE)
;  思路: 外层用 SI 计数，内层用 CX；用 DEC + JNZ 代替 LOOP，
;        这样两个循环可以使用不同的计数器。
;===========================================================
        .MODEL SMALL
        .DATA
        dummy   DB 0
        .CODE
START:  MOV AX,@DATA
        MOV DS,AX

        MOV BL,'a'              ; 从字符 'a' 开始
        MOV SI,2                ; 外层计数：2 行（不用 CX）

OUTER:  MOV CX,13               ; 内层计数：每行 13 个

INNER:  MOV DL,BL
        MOV AH,2                ; DOS 功能 2：显示单个字符
        INT 21H
        INC BL                  ; 下一个字母
        DEC CX                  ; CX--
        JNZ INNER               ; CX != 0 则继续内层

        MOV DL,0DH              ; 回车
        MOV AH,2
        INT 21H
        MOV DL,0AH              ; 换行
        MOV AH,2
        INT 21H

        DEC SI                  ; SI--
        JNZ OUTER               ; SI != 0 则继续外层

        MOV AX,4C00H            ; 正常退出
        INT 21H
END START
