;===========================================================
;  MUL9C.ASM -- Turbo C 3.0 对 mul9.c 生成的反汇编（已加注释）
;
;  说明:
;    * 本文件由 `TCC -ms -S MUL9C.C` 生成，指令与标号保持原样；
;    * 中文注释为后加，用于说明 C 语句与 8086 指令的对应关系；
;    * 本文件用于阅读，不参与 MASM 构建。
;
;  编译命令:
;    TCC -IC:\TURBOC3\INCLUDE -LC:\TURBOC3\LIB -ms -S MUL9C.C
;===========================================================

_TEXT   segment byte public 'CODE'
DGROUP  group   _DATA,_BSS
        assume  cs:_TEXT,ds:DGROUP

_TEXT   segment byte public 'CODE'
;-----------------------------------------------------------
;  int main(void)
;-----------------------------------------------------------
_main   proc near
        push    bp              ; 保存调用者的 BP
        mov     bp,sp           ; 建立当前栈帧
        push    si              ; 保存 SI（后面用 SI 存放 i）
        push    di              ; 保存 DI（后面用 DI 存放 j）

;       printf("The 9mul9 table:\n");
        mov     ax,offset DGROUP:s@
        push    ax              ; 参数：格式串地址
        call    near ptr _printf
        pop     cx              ; cdecl：调用者清理 1 个参数

;       for (i = 9; i >= 1; i--)
        mov     si,9            ; SI = i = 9
        jmp     short @1@366    ; 先跳到循环条件

;------- 外层循环体：内层 j 从 1 开始 ----------------
@1@58:
        mov     di,1            ; DI = j = 1
        jmp     short @1@226    ; 跳到内层循环条件

;------- 内层循环体：printf("%d*%d=%d", i, j, i*j) ----
@1@86:
        mov     ax,si           ; AX = i
        imul    di              ; DX:AX = i * j（有符号乘法）
        push    ax              ; 第 4 个参数：乘积（先压入）
        push    di              ; 第 3 个参数：j
        push    si              ; 第 2 个参数：i
        mov     ax,offset DGROUP:s@+18
        push    ax              ; 第 1 个参数：格式串 "%d*%d=%d"
        call    near ptr _printf
        add     sp,8            ; cdecl：4 个 word 参数 = 8 字节，由调用者清理

;       if (j < i) putchar(' ');
        cmp     di,si           ; 比较 j 与 i
        jge     short @1@198    ; j >= i 则跳过空格
;       —— 下面是 Turbo C 对 putchar 的内联优化 ——
        inc     word ptr DGROUP:__streams+16
        jge     short @1@170
        mov     bx,word ptr DGROUP:__streams+26
        inc     word ptr DGROUP:__streams+26
        mov     al,32           ; ' ' = 32
        mov     byte ptr [bx],al
        mov     ah,0
        jmp     short @1@198
@1@170:
        mov     ax,offset DGROUP:__streams+16
        push    ax
        mov     al,32
        push    ax
        call    near ptr __fputc
        pop     cx
        pop     cx

;       j++，然后判断 j <= i
@1@198:
        inc     di              ; j++
@1@226:
        cmp     di,si
        jle     short @1@86     ; j <= i 则继续内层

;       putchar('\n')
        inc     word ptr DGROUP:__streams+16
        jge     short @1@310
        mov     bx,word ptr DGROUP:__streams+26
        inc     word ptr DGROUP:__streams+26
        mov     al,10           ; '\n' = 10
        mov     byte ptr [bx],al
        mov     ah,0
        jmp     short @1@338
@1@310:
        mov     ax,offset DGROUP:__streams+16
        push    ax
        mov     al,10
        push    ax
        call    near ptr __fputc
        pop     cx
        pop     cx

;       i--，然后判断 i >= 1
@1@338:
        dec     si              ; i--
@1@366:
        cmp     si,1
        jge     short @1@58     ; i >= 1 则继续外层

;       return 0
        xor     ax,ax
        jmp     short @1@422

;------- 函数返回：恢复被保存的寄存器 ----------------
@1@422:
        pop     di              ; 恢复 DI
        pop     si              ; 恢复 SI
        pop     bp              ; 恢复 BP
        ret                     ; 返回调用者
_main   endp

_TEXT   ends
_DATA   segment word public 'DATA'
s@      label   byte
        db      'The 9mul9 table:'
        db      10
        db      0
        db      '%d*%d=%d'
        db      0
_DATA   ends
        end
