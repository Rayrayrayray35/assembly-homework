;===========================================================
;  SUM1.ASM —— 求 1+2+...+100, 结果保存在【寄存器】中
;  结果 = 5050 (>255, 已超过一个字节, 必须用 16 位寄存器/字)
;  运行:  D:\>sum1
;        1+2+...+100 = 5050
;  注意: 显示字符串用的 INT 21H 功能 09H 会把 AH 置成 09H,
;        所以务必“先显示提示、后计算”, 以免破坏结果高字节！
;===========================================================
        .MODEL SMALL
        .STACK 100H

        .DATA
MSG     DB  '1+2+...+100 = $'

        .CODE
START:  MOV AX,@DATA
        MOV DS,AX

;----- 先显示提示(它会修改 AH) -----
        LEA DX,MSG
        MOV AH,09H
        INT 21H

;----- 累加: 结果放在寄存器 AX 中 -----
        XOR AX,AX               ; AX = 0  (★累加器就是寄存器)
        MOV CX,100              ; 循环 100 次
        MOV BX,1                ; 加数 1,2,3,...,100
SUMLP:  ADD AX,BX               ; AX = AX + 加数
        INC BX
        LOOP SUMLP              ; CX=CX-1; 不为 0 则继续

;----- 输出结果 -----
        CALL PUTDEC             ; 把 AX 以十进制输出
        CALL CRLF
        MOV AX,4C00H
        INT 21H

;----------------------------------------------------------
; CRLF: 输出回车换行
;----------------------------------------------------------
CRLF    PROC
        MOV DL,0DH
        MOV AH,02H
        INT 21H
        MOV DL,0AH
        MOV AH,02H
        INT 21H
        RET
CRLF    ENDP

;----------------------------------------------------------
; PUTDEC: 把 AX(0..65535)以十进制输出
;----------------------------------------------------------
PUTDEC  PROC
        XOR CX,CX
        MOV BX,10
PD_LOOP:
        XOR DX,DX
        DIV BX                  ; DX:AX / 10 -> 商在 AX, 余数在 DX
        PUSH DX                 ; 余数(当前最低位)压栈
        INC CX
        TEST AX,AX
        JNZ PD_LOOP             ; 商不为 0 继续
PD_OUT: POP DX
        ADD DL,'0'
        MOV AH,02H
        INT 21H
        LOOP PD_OUT
        RET
PUTDEC  ENDP

        END START
