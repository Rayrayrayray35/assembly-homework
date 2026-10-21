;===========================================================
;  SUM3.ASM —— 求 1+2+...+100, 结果保存在【栈】中
;  用 BP 指向栈顶, 在栈上开出一个字作为累加和, 通过 [BP-2] 访问。
;  运行:  D:\>sum3
;        1+2+...+100 = 5050
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

;----- 在栈上开辟一个字作为累加和 -----
        MOV BP,SP               ; BP 指向当前栈顶
        SUB SP,2                ; ★栈指针下移 2 字节, 相当于申请一个“栈变量”
        MOV WORD PTR [BP-2],0   ; 该栈变量初值 = 0

;----- 累加: 结果保存在栈中 -----
        MOV CX,100              ; 循环 100 次
        MOV BX,1                ; 加数
SUMLP:  MOV AX,[BP-2]           ; 从栈中取出当前和
        ADD AX,BX               ; 加上加数
        MOV [BP-2],AX           ; 写回栈中
        INC BX
        LOOP SUMLP

;----- 输出结果 -----
        MOV AX,[BP-2]           ; 从栈中取出最终结果
        ADD SP,2                ; 释放栈空间
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
