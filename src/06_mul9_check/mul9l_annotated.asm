;===========================================================
;  mul9l_annotated.asm
;  TCC -ms -S MUL9L.C 生成的反汇编（局部 table 版本）
;
;  说明:
;    只保留与本题逻辑相关的部分，省略 ?debug 宏、库函数
;    声明等由编译器自动插入、与算法无关的行。
;    原文件见 mul9l_generated.asm。
;
;  关键观察:
;    局部数组 table 分配在栈上（SUB SP,82）；
;    初始化数据仍以“隐藏模板”的形式放在 _DATA 段，
;    函数进入时用 N_SCOPY@ 把 81 字节从模板拷到栈上。
;    访问形式为 [BP-82] + i*9 + j，即 SS 段 + BP 偏移。
;===========================================================

_TEXT   segment byte public 'CODE'
        assume cs:_TEXT, ds:DGROUP

_main   proc near
        push    bp              ; 保存调用者的 BP
        mov     bp,sp           ; 建立 main 的栈帧
        sub     sp,82           ; ★在栈上分配 82 字节（81 向上取偶）
        push    si              ; 保存 SI（i）
        push    di              ; 保存 DI（j）

;       unsigned char table[9][9] = { ... };
;       —— 局部数组的初始化：从 _DATA 中的隐藏模板拷贝到栈
        lea     ax,word ptr [bp-82]   ; 目标地址：栈上的 table
        push    ss
        push    ax                    ; 目标段:偏移 = SS:[BP-82]
        mov     ax,offset DGROUP:d@w+0; 源地址：_DATA 中的模板
        push    ds
        push    ax                    ; 源段:偏移 = DS:模板
        mov     cx,81                 ; 拷贝 81 字节
        call    near ptr N_SCOPY@     ; 编译器内部的 far copy 例程

;       printf("x y\n");
        mov     ax,offset DGROUP:s@
        push    ax
        call    near ptr _printf
        pop     cx

;       for (i = 0; i < 9; i++)
        xor     si,si
        jmp     short @1@226

@1@58:
;       for (j = 0; j < 9; j++)
        xor     di,di
        jmp     short @1@170

@1@86:
;       if (table[i][j] != (i + 1) * (j + 1))
        mov     ax,si
        mov     dx,9
        imul    dx              ; DX:AX = i * 9
        add     ax,di           ; AX = i*9 + j
        lea     dx,word ptr [bp-82]   ; ★局部数组基址（栈上）
        add     ax,dx           ; AX = BP-82 + i*9 + j
        mov     bx,ax
        mov     al,byte ptr [bx]      ; 实际值：SS:[BX]
        mov     ah,0
        push    ax

        mov     ax,si
        inc     ax              ; i+1
        mov     dx,di
        inc     dx              ; j+1
        imul    dx              ; 期望值
        pop     dx              ; 实际值
        cmp     dx,ax
        je      short @1@142

;       printf("%d %d error\n", i + 1, j + 1);
        mov     ax,di
        inc     ax
        push    ax
        mov     ax,si
        inc     ax
        push    ax
        mov     ax,offset DGROUP:s@+5
        push    ax
        call    near ptr _printf
        add     sp,6

@1@142:
        inc     di
@1@170:
        cmp     di,9
        jl      short @1@86

        inc     si
@1@226:
        cmp     si,9
        jl      short @1@58

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
        mov     sp,bp           ; ★释放 82 字节局部区
        pop     bp              ; 恢复 BP
        ret
_main   endp

_TEXT   ends

;-----------------------------------------------------------
; _DATA 段：局部数组的“隐藏初始化模板”（无符号名）
;          d@w 位于 _DATA 偏移 0，N_SCOPY@ 从这里拷贝 81 字节
;-----------------------------------------------------------
_DATA   segment word public 'DATA'
d@      label byte
d@w     label word
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

_TEXT   segment byte public 'CODE'
_TEXT   ends
        extrn   N_SCOPY@:far
        public  _main
        extrn   _printf:near
        end
