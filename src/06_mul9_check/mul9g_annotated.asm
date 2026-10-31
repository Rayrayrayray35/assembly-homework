;===========================================================
;  mul9g_annotated.asm
;  TCC -ms -S MUL9G.C 生成的反汇编（全局 table 版本）
;
;  说明:
;    只保留与本题逻辑相关的部分，省略 ?debug 宏、库函数
;    声明等由编译器自动插入、与算法无关的行。
;    原文件见 mul9g_generated.asm。
;
;  关键观察:
;    全局数组 table 放在 _DATA 段，链接时写入可执行文件；
;    程序启动时由 DOS 装入，不需要运行时初始化代码。
;    访问形式为 DGROUP:_table[bx+di]，即 DS 段 + 16 位偏移。
;===========================================================

_TEXT   segment byte public 'CODE'
        assume cs:_TEXT, ds:DGROUP

_main   proc near
        push    bp              ; 保存调用者的 BP
        mov     bp,sp           ; 建立 main 的栈帧
        push    si              ; 保存 SI（编译器把 i 放在 SI）
        push    di              ; 保存 DI（编译器把 j 放在 DI）

;       printf("x y\n");
        mov     ax,offset DGROUP:s@
        push    ax              ; 压入格式串地址
        call    near ptr _printf
        pop     cx              ; cdecl：调用者清理 1 个 word 参数

;       for (i = 0; i < 9; i++)
        xor     si,si           ; i = 0
        jmp     short @1@226    ; 先跳到循环条件

@1@58:
;       for (j = 0; j < 9; j++)
        xor     di,di           ; j = 0
        jmp     short @1@170    ; 先跳到内层循环条件

@1@86:
;       if (table[i][j] != (i + 1) * (j + 1))
        mov     ax,si           ; AX = i
        mov     dx,9
        imul    dx              ; DX:AX = i * 9
        mov     bx,ax           ; BX = i * 9（行偏移）
        mov     al,byte ptr DGROUP:_table[bx+di]
                                ; ★全局数组寻址：DS:[BX+DI]
                                ;   BX = i*9, DI = j
        mov     ah,0            ; 零扩展为 16 位
        push    ax              ; 保存表中的实际值

        mov     ax,si
        inc     ax              ; AX = i + 1
        mov     dx,di
        inc     dx              ; DX = j + 1
        imul    dx              ; DX:AX = (i+1)*(j+1) = 期望值
        pop     dx              ; DX = 表中的实际值
        cmp     dx,ax           ; 实际值 vs 期望值
        je      short @1@142    ; 相等 -> 跳过输出

;       printf("%d %d error\n", i + 1, j + 1);
        mov     ax,di
        inc     ax
        push    ax              ; 第 3 个参数：j+1
        mov     ax,si
        inc     ax
        push    ax              ; 第 2 个参数：i+1
        mov     ax,offset DGROUP:s@+5
        push    ax              ; 第 1 个参数：格式串
        call    near ptr _printf
        add     sp,6            ; cdecl：清理 3 个 word 参数

@1@142:
        inc     di              ; j++
@1@170:
        cmp     di,9
        jl      short @1@86     ; j < 9 继续内层

        inc     si              ; i++
@1@226:
        cmp     si,9
        jl      short @1@58     ; i < 9 继续外层

;       printf("accomplish!\n");
        mov     ax,offset DGROUP:s@+18
        push    ax
        call    near ptr _printf
        pop     cx

;       return 0;
        xor     ax,ax
        jmp     short @1@282

@1@282:
        pop     di              ; 恢复 DI
        pop     si              ; 恢复 SI
        pop     bp              ; 恢复 BP
        ret
_main   endp

_TEXT   ends

;-----------------------------------------------------------
; 全局数据段：table 在编译/链接时直接写入可执行文件
;-----------------------------------------------------------
_DATA   segment word public 'DATA'
_table  label byte
        db      7,2,3,4,5,6,7,8,9
        db      2,4,7,8,10,12,14,16,18
        db      3,6,9,12,15,18,21,24,27
        db      4,8,12,16,7,24,28,32,36
        db      5,10,15,20,25,30,35,40,45
        db      6,12,18,24,30,7,42,48,54
        db      7,14,21,28,35,42,49,56,63
        db      8,16,24,32,40,48,56,7,72
        db      9,18,27,36,45,54,63,72,81

s@      label byte
        db      'x y',10,0
        db      '%d %d error',10,0
        db      'accomplish!',10,0
_DATA   ends

        public  _main
        public  _table          ; 全局符号，其他模块也可引用
        extrn   _printf:near
        end
