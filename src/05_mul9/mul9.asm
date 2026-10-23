;===========================================================
;  MUL9.ASM -- 九九乘法表（9×9）
;  题目: 作业题目4 · 乘法指令和过程调用
;
;  要求:
;    1. 用 CALL / RET 实现过程调用；
;       过程中使用主过程寄存器时，必须 PUSH/POP 保存与恢复。
;    2. 双重循环：外层 9..1，内层 1..row。
;    3. 乘法用 MUL 指令，结果用十进制输出。
;
;  运行:
;    C:\>MUL9
;    The 9mul9 table:
;    9*1=9 9*2=18 ... 9*9=81
;    ...
;    1*1=1
;===========================================================
        .MODEL SMALL
        .STACK 100H

        .DATA
MSG     DB  'The 9mul9 table:',0DH,0AH,'$'

        .CODE
START:  MOV AX,@DATA
        MOV DS,AX

        LEA DX,MSG              ; 显示表头
        MOV AH,09H
        INT 21H

        MOV BX,9                ; BX = 外层行号（9..1）

ROW_LOOP:
        MOV CX,1                ; CX = 内层列号（1..BX）

COL_LOOP:
        MOV AX,BX               ; 输出 row
        CALL PRINT_DEC

        MOV DL,'*'              ; 输出 '*'
        CALL PRINT_CHAR

        MOV AX,CX               ; 输出 col
        CALL PRINT_DEC

        MOV DL,'='              ; 输出 '='
        CALL PRINT_CHAR

        MOV AX,BX               ; AX = row
        MUL CX                  ; AX = row * col（结果 <= 81，DX=0）
        CALL PRINT_DEC          ; 输出乘积

        CMP CX,BX               ; 该行最后一个？
        JAE END_ROW             ; col >= row -> 换行
        MOV DL,' '              ; 否则输出一个空格
        CALL PRINT_CHAR
        INC CX
        JMP COL_LOOP

END_ROW:
        CALL NEWLINE            ; 一行结束，回车换行
        DEC BX                  ; 下一行（行号减 1）
        JNZ ROW_LOOP            ; BX != 0 继续

        MOV AX,4C00H            ; 返回 DOS
        INT 21H

;-----------------------------------------------------------
; PRINT_DEC: 把 AX 按无符号十进制输出
; 过程中使用 AX/BX/CX/DX，所以入口全部 PUSH，出口全部 POP，
; 保证主过程的 BX（行号）、CX（列号）不被破坏。
;-----------------------------------------------------------
PRINT_DEC PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        MOV CX,0                ; CX = 位数
        MOV BX,10               ; 除数为 10
PD_DIV:
        MOV DX,0                ; DX:AX / 10
        DIV BX
        PUSH DX                 ; 余数压栈
        INC CX
        CMP AX,0
        JNE PD_DIV

PD_OUT:
        POP DX                  ; 逆序弹出：高位先输出
        ADD DL,'0'
        MOV AH,02H
        INT 21H
        LOOP PD_OUT

        POP DX
        POP CX
        POP BX
        POP AX
        RET
PRINT_DEC ENDP

;-----------------------------------------------------------
; PRINT_CHAR: 输出 DL 中的一个字符
; INT 21H 的 02H 功能会用到 AH，因此保存/恢复 AX。
;-----------------------------------------------------------
PRINT_CHAR PROC
        PUSH AX
        PUSH DX
        MOV AH,02H
        INT 21H
        POP DX
        POP AX
        RET
PRINT_CHAR ENDP

;-----------------------------------------------------------
; NEWLINE: 输出 CR LF
;-----------------------------------------------------------
NEWLINE PROC
        PUSH AX
        PUSH DX
        MOV DL,0DH
        MOV AH,02H
        INT 21H
        MOV DL,0AH
        MOV AH,02H
        INT 21H
        POP DX
        POP AX
        RET
NEWLINE ENDP

END START
