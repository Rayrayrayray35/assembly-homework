;===========================================================
;  SUMN.ASM —— 用户输入 1~100 内的任意整数 n, 求 1+2+...+n
;  并输出十进制结果。输入用 DOS 功能调用 0AH(缓冲输入)。
;  运行:  D:\>sumn
;        Please input n (1~100):
;        100
;        1+2+...+n = 5050
;  注意: 09H 会修改 AH, 故先输出提示字符串, 再做累加,
;        保证累加结果(AX)不被破坏。
;===========================================================
        .MODEL SMALL
        .STACK 100H

        .DATA
MSG1    DB  'Please input n (1~100):',0DH,0AH,'$'
MSG2    DB  '1+2+...+n = $'
BUF     DB  5                   ; 缓冲区最大字符数
        DB  0                   ; 实际读入字符数
        DB  5 DUP(0)            ; 字符内容

        .CODE
START:  MOV AX,@DATA
        MOV DS,AX

;----- 输入 n -----
        LEA DX,MSG1
        MOV AH,09H
        INT 21H
        CALL READLINE           ; 读入一行到 BUF
        CALL DEC2VAL            ; 字符串 -> 数值, 结果在 BX(即 n)
        MOV CX,BX               ; CX = n, 作为循环次数

;----- 先显示结果标签(它会修改 AH) -----
        LEA DX,MSG2
        MOV AH,09H
        INT 21H

;----- 计算 1+2+...+n -----
        XOR AX,AX               ; 累加和
        JCXZ DONE               ; n=0 则结果为 0
        MOV SI,1                ; 加数 1,2,...,n
SUMLP:  ADD AX,SI
        INC SI
        LOOP SUMLP
DONE:
;----- 输出结果 -----
        CALL PUTDEC             ; 输出 AX 的十进制
        CALL CRLF
        MOV AX,4C00H
        INT 21H

;----------------------------------------------------------
; READLINE: 读入一行(功能 0AH)到 BUF, 并补一个回车换行
;----------------------------------------------------------
READLINE PROC
        LEA DX,BUF
        MOV AH,0AH
        INT 21H
        MOV DL,0DH              ; 补回车换行
        MOV AH,02H
        INT 21H
        MOV DL,0AH
        MOV AH,02H
        INT 21H
        RET
READLINE ENDP

;----------------------------------------------------------
; DEC2VAL: 把 BUF 中的十进制字符串转成数值, 结果存 BX
;----------------------------------------------------------
DEC2VAL PROC
        MOV BX,0
        MOV SI,2                ; 字符从偏移 2 开始
        XOR CX,CX
        MOV CL,BUF+1            ; 实际长度
        JCXZ D2V_RET
D2V_LOOP:
        MOV AL,BUF[SI]
        CMP AL,'0'              ; 非数字字符(如回车)跳过
        JB  D2V_NEXT
        CMP AL,'9'
        JA  D2V_NEXT
        SUB AL,'0'
        XOR AH,AH
        PUSH AX                 ; 保存当前位数字
        MOV AX,BX
        MOV DX,10
        MUL DX                  ; DX:AX = BX * 10
        MOV BX,AX
        POP AX
        ADD BX,AX
D2V_NEXT:
        INC SI
        LOOP D2V_LOOP
D2V_RET:
        RET
DEC2VAL ENDP

;----------------------------------------------------------
; CRLF: 回车换行
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
