;===========================================================
;  程序名 : EXCHANGE.ASM
;  功能   : 进制转换
;           (1) 基本要求: 输入 1~2 位十六进制数, 输出对应十进制数;
;           (2) 追加要求: 输入十进制数(0~255), 输出对应十六进制数。
;  运行   : D:\>exchange
;           Please input a Hex number:
;           ff
;           The Dec number:
;           255
;  环境   : MASM 5.10 + LINK  (DOS 16 位 .EXE)
;  日期   : 2026-10-16
;===========================================================
        .MODEL SMALL
        .STACK 100H

;======================= 数据段 =======================
        .DATA
MSG1    DB  'Please input a Hex number:',0DH,0AH,'$'
MSG2    DB  'The Dec number:',0DH,0AH,'$'
MSG3    DB  0DH,0AH,'Please input a Dec number:',0DH,0AH,'$'
MSG4    DB  'The Hex number:',0DH,0AH,'$'
BUF     DB  6                   ; 缓冲区最大字符数
        DB  0                   ; 实际读入字符数(由 0AH 填入)
        DB  6 DUP(0)            ; 字符内容

;======================= 代码段 =======================
        .CODE
START:  MOV AX,@DATA
        MOV DS,AX

;-------- 第一部分: 十六进制 -> 十进制 (基本要求) --------
        LEA DX,MSG1             ; 提示
        MOV AH,09H
        INT 21H
        CALL READLINE           ; 读入一行(带回显)
        CALL HEX2VAL            ; 结果 -> BL
        LEA DX,MSG2
        MOV AH,09H
        INT 21H
        MOV AL,BL
        CALL PUTDEC             ; 输出十进制

;-------- 第二部分: 十进制 -> 十六进制 (追加要求) --------
        LEA DX,MSG3
        MOV AH,09H
        INT 21H
        CALL READLINE
        CALL DEC2VAL            ; 结果 -> BL
        LEA DX,MSG4
        MOV AH,09H
        INT 21H
        MOV AL,BL
        CALL PUTHEX             ; 输出十六进制

        MOV DL,0DH              ; 结尾换行
        MOV AH,02H
        INT 21H
        MOV DL,0AH
        MOV AH,02H
        INT 21H

        MOV AX,4C00H            ; 返回 DOS
        INT 21H

;----------------------------------------------------------
; READLINE: 用 DOS 功能 0AH 读入一行到 BUF, 并补一个回车换行
;----------------------------------------------------------
READLINE PROC
        LEA DX,BUF
        MOV AH,0AH
        INT 21H
        MOV DL,0DH              ; 补回车换行, 使输出另起一行
        MOV AH,02H
        INT 21H
        MOV DL,0AH
        MOV AH,02H
        INT 21H
        RET
READLINE ENDP

;----------------------------------------------------------
; HEXDIG: 把 AL 中的 ASCII 字符转成 0..15
;         合法返回 0..15 且 CF=0, 非法则 CF=1
;----------------------------------------------------------
HEXDIG  PROC
        CMP AL,'0'
        JB  HD_BAD
        CMP AL,'9'
        JBE HD_NUM
        AND AL,0DFH             ; 小写字母转大写
        CMP AL,'A'
        JB  HD_BAD
        CMP AL,'F'
        JA  HD_BAD
        SUB AL,'A'-10           ; 'A' -> 10
        CLC
        RET
HD_NUM: SUB AL,'0'              ; '0'..'9' -> 0..9
        CLC
        RET
HD_BAD: STC
        RET
HEXDIG  ENDP

;----------------------------------------------------------
; HEX2VAL: 把 BUF 中的字符串按十六进制累加, 结果存入 BL
;----------------------------------------------------------
HEX2VAL PROC
        MOV BX,0                ; 累加器
        MOV SI,2                ; BUF 中字符从偏移 2 开始
        XOR CX,CX
        MOV CL,BUF+1            ; 实际读入的字符数
        JCXZ H2V_RET
H2V_LOOP:
        MOV AL,BUF[SI]
        CALL HEXDIG
        JC   H2V_NEXT           ; 非法字符(如回车)跳过
        SHL BX,1                ; BX = BX * 16
        SHL BX,1
        SHL BX,1
        SHL BX,1
        XOR AH,AH
        ADD BX,AX
H2V_NEXT:
        INC SI
        LOOP H2V_LOOP
H2V_RET:
        RET
HEX2VAL ENDP

;----------------------------------------------------------
; DEC2VAL: 把 BUF 中的字符串按十进制累加, 结果存入 BL
;----------------------------------------------------------
DEC2VAL PROC
        MOV BX,0
        MOV SI,2
        XOR CX,CX
        MOV CL,BUF+1
        JCXZ D2V_RET
D2V_LOOP:
        MOV AL,BUF[SI]
        CMP AL,'0'
        JB  D2V_NEXT            ; 非数字字符跳过
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
; PUTDEC: 把 AL 中的无符号数(0..255)以十进制输出
;----------------------------------------------------------
PUTDEC  PROC
        XOR AH,AH
        XOR CX,CX
        MOV BX,10
PD_LOOP:
        XOR DX,DX
        DIV BX                  ; AX=商, DX=余数
        PUSH DX                 ; 余数压栈
        INC CX
        TEST AX,AX
        JNZ PD_LOOP
PD_PRINT:
        POP DX
        ADD DL,'0'
        MOV AH,02H
        INT 21H
        LOOP PD_PRINT
        RET
PUTDEC  ENDP

;----------------------------------------------------------
; PUTHEX: 把 BL 中的数(0..255)以十六进制输出(无前导零)
;----------------------------------------------------------
PUTHEX  PROC
        MOV AL,BL
        CMP AL,16
        JB  PH_LOW              ; 只有个位
        MOV DL,AL               ; 高 4 位
        MOV CL,4
        SHR DL,CL
        CALL PHDIG
PH_LOW: MOV DL,BL
        AND DL,0FH              ; 低 4 位
        CALL PHDIG
        RET
PUTHEX  ENDP

;----------------------------------------------------------
; PHDIG: 把 DL 中的 0..15 以十六进制字符输出
;----------------------------------------------------------
PHDIG   PROC
        CMP DL,10
        JB  PHD_NUM
        ADD DL,'A'-10
        JMP PHD_OUT
PHD_NUM:
        ADD DL,'0'
PHD_OUT:
        MOV AH,02H
        INT 21H
        RET
PHDIG   ENDP

        END START
