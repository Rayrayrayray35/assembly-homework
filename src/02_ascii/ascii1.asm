;===========================================================
;  ASCII1.ASM -- 打印小写字母 a..z，每行 13 个（LOOP 版）
;  环境: MASM 5.10 + LINK，16 位 DOS (.EXE)
;  思路: 外层 2 行，内层 13 个；内层也要用 CX，
;        所以进入内层前 PUSH CX，退出内层后 POP CX。
;===========================================================
        .MODEL SMALL
        .DATA
        dummy   DB 0
        .CODE
START:  MOV AX,@DATA
        MOV DS,AX

        MOV CX,2                ; 外层循环：2 行
        MOV BL,'a'              ; 从字符 'a' 开始

OUTER:  PUSH CX                 ; 保存外层计数器（内层会复用 CX）
        MOV CX,13               ; 内层循环：每行 13 个

INNER:  MOV DL,BL
        MOV AH,2                ; DOS 功能 2：显示单个字符
        INT 21H
        INC BL                  ; 下一个字母
        LOOP INNER              ; CX--，不为 0 则继续

        MOV DL,0DH              ; 回车
        MOV AH,2
        INT 21H
        MOV DL,0AH              ; 换行
        MOV AH,2
        INT 21H

        POP CX                  ; 恢复外层计数器
        LOOP OUTER

        MOV AX,4C00H            ; 正常退出
        INT 21H
END START
