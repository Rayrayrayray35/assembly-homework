;===========================================================
;  MUL9CHK.ASM -- 9x9 乘法表纠错
;
;  功能:
;    逐项检查 data 段中的 9x9 乘法表，若 table[row][col]
;    不等于 row*col，则在屏幕上输出:
;        row col error
;    全部检查完后输出 "accomplish!"。
;
;  要求对应:
;    1. 用 CALL/RET 实现过程调用；过程内使用主过程寄存器，
;       入口 PUSH、出口 POP，保证现场恢复。
;    2. 双重循环：外层 row=1..9，内层 col=1..9。
;    3. 数据段寻址：table[(row-1)*9 + (col-1)]。
;    4. 乘法指令 MUL；行号/列号均为 1 位十进制，直接 +'0' 输出。
;
;  环境: MASM 5.10 + LINK 3.64 (DOS 16-bit .EXE)
;===========================================================

stack segment stack
        db 256 dup(0)
stack ends

data segment
table   db 7,2,3,4,5,6,7,8,9
        db 2,4,7,8,10,12,14,16,18
        db 3,6,9,12,15,18,21,24,27
        db 4,8,12,16,7,24,28,32,36
        db 5,10,15,20,25,30,35,40,45
        db 6,12,18,24,30,7,42,48,54
        db 7,14,21,28,35,42,49,56,63
        db 8,16,24,32,40,48,56,7,72
        db 9,18,27,36,45,54,63,72,81

header  db 'x y',0dh,0ah,'$'
errmsg  db ' error',0dh,0ah,'$'
done    db 'accomplish!',0dh,0ah,'$'
data ends

code segment
        assume cs:code, ds:data, ss:stack

start:
        mov ax,data             ; 初始化数据段寄存器
        mov ds,ax

        lea dx,header           ; 输出表头 "x y"
        call print_string

        call check_table        ; 检查整个乘法表

        lea dx,done             ; 输出 "accomplish!"
        call print_string

        mov ax,4c00h            ; 返回 DOS
        int 21h

;-----------------------------------------------------------
; check_table:
;   双重循环检查 9x9 表。
;   使用 AX/BX/CX/DX/SI，入口全部保存，出口逆序恢复。
;   BX = row (1..9)
;   CX = col (1..9)
;-----------------------------------------------------------
check_table proc
        push ax
        push bx
        push cx
        push dx
        push si

        mov bx,1                ; row = 1

row_loop:
        mov cx,1                ; col = 1

col_loop:
        ; ---- 计算期望值 expected = row * col ----
        mov ax,bx
        mul cx                  ; DX:AX = AX * CX
        push ax                 ; 保存 expected（本题 <= 81）

        ; ---- 计算数组下标 index = (row-1)*9 + (col-1) ----
        mov si,bx
        dec si                  ; SI = row - 1
        mov ax,si
        mov dx,9
        mul dx                  ; AX = (row-1)*9
        mov si,ax
        add si,cx
        dec si                  ; SI = (row-1)*9 + (col-1)

        mov al,table[si]        ; AL = 表中实际值
        mov ah,0                ; AX = 实际值（零扩展）

        pop dx                  ; DX = expected
        cmp ax,dx
        je  next_item           ; 相等 -> 检查下一项

        ; ---- 不相等：输出 "row col error" ----
        mov dl,bl               ; row
        add dl,'0'
        call print_char

        mov dl,' '
        call print_char

        mov dl,cl               ; col
        add dl,'0'
        call print_char

        lea dx,errmsg
        call print_string

next_item:
        inc cx
        cmp cx,9
        jle col_loop            ; col <= 9 继续内层

        inc bx
        cmp bx,9
        jle row_loop            ; row <= 9 继续外层

        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
check_table endp

;-----------------------------------------------------------
; print_char: 输出 DL 中的字符
; 保存 AX/DX，因为 INT 21H 的 02H 功能要修改 AH。
;-----------------------------------------------------------
print_char proc
        push ax
        push dx
        mov ah,02h
        int 21h
        pop dx
        pop ax
        ret
print_char endp

;-----------------------------------------------------------
; print_string: 输出 DX 指向的、以 '$' 结尾的字符串
; 保存 AX/DX。
;-----------------------------------------------------------
print_string proc
        push ax
        push dx
        mov ah,09h
        int 21h
        pop dx
        pop ax
        ret
print_string endp

code ends
        end start
