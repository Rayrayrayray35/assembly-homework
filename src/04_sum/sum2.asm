;===========================================================
;  SUM2.ASM —— 求 1+2+...+100, 结果保存在【数据段】变量中
;  结果 = 5050 (>255, 已经超过一个字节, 用 DW 定义字变量)
;  运行:  D:\>sum2
;        1+2+...+100 = 5050
;===========================================================
        .MODEL SMALL
        .STACK 100H

        .DATA
SUM     DW  0                   ; ★结果变量, 放在数据段
MSG     DB  '1+2+...+100 = $'

        .CODE
START:  MOV AX,@DATA
        MOV DS,AX

;----- 先显示提示(它会修改 AH) -----
        LEA DX,MSG
        MOV AH,09H
        INT 21H

;----- 累加: 结果保存在数据段变量 SUM 中 -----
        MOV SUM,0
        MOV CX,100              ; 循环 100 次
        MOV BX,1                ; 加数
SUMLP:  MOV AX,SUM              ; 从数据段取出当前和
        ADD AX,BX               ; 加上加数
        MOV SUM,AX              ; 再写回数据段
        INC BX
        LOOP SUMLP

;----- 输出结果 -----
        MOV AX,SUM              ; 从数据段取最终结果
        CALL PUTDEC
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
        DIV BX
        PUSH DX
        INC CX
        TEST AX,AX
        JNZ PD_LOOP
PD_OUT: POP DX
        ADD DL,'0'
        MOV AH,02H
        INT 21H
        LOOP PD_OUT
        RET
PUTDEC  ENDP

        END START
