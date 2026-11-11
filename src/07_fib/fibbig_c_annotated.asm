; ==============================================================
; fibbig_c_annotated.asm
;   Turbo C++ 3.0  `TCC -ms -S FIBBIG.C` 生成的汇编,
;   删去 ?debug 宏与调试信息, 逐条加中文注释.
;
; 与 FIB.ASM 相同的算法: 递归 + 记忆化 + 24 位十进制大数.
; 重点:
;   1) memo/done 是全局数组, 放在 _BSS 段
;   2) 递归函数用 [bp+4] 取参数, [bp-2] 存局部变量 carry
;   3) 二维数组寻址: &memo[n][i] = memo + n*24 + i, 用 IMUL 算 n*24
;   4) 编译器把 i 放在 SI, 循环变量也占寄存器
; ==============================================================

_TEXT   segment byte public 'CODE'
_TEXT   ends
DGROUP  group   _DATA,_BSS
        assume  cs:_TEXT, ds:DGROUP

_DATA   segment word public 'DATA'
d@      label   byte
d@w     label   word
_DATA   ends

_BSS    segment word public 'BSS'
b@      label   byte
b@w     label   word
_BSS    ends

_TEXT   segment byte public 'CODE'
        assume  cs:_TEXT

;--------------------------------------------------------------
; static void fib(int n)
;
; 栈帧(每层):
;       [bp+4] 参数 n
;       [bp+2] 返回地址
;       [bp+0] 旧 bp
;       [bp-2] 局部变量 carry
;       [bp-4] 保存的 si
;       [bp-6] 保存的 di
;   每层 12 字节 (含返回地址与参数).
;--------------------------------------------------------------
fib     proc    near
        push    bp
        mov     bp,sp
        sub     sp,2            ; 局部变量 carry 在 [bp-2]
        push    si              ; si/di 由被调函数保存
        push    di

;
;       unsigned carry = 0;
;
        mov     word ptr [bp-2],0
;
;       if (done[n]) return;
;
        mov     bx,word ptr [bp+4]              ; BX = n
        cmp     byte ptr DGROUP:done[bx],0      ; done[n] == 0 ?
        je      short @1@86                     ; 0 -> 没算过, 继续
        jmp     @1@282                          ; 非 0 -> 直接返回(记忆化)
@1@86:
;
;       if (n < 2) { memo[n][0] = n; done[n] = 1; return; }
;
        cmp     word ptr [bp+4],2
        jge     short @1@142
        mov     ax,word ptr [bp+4]      ; AX = n
        mov     dx,24                   ; ★ n * 24 = n 在 memo 中的字节偏移
        imul    dx                      ; DX:AX = n * 24
        mov     dl,byte ptr [bp+4]      ; DL = n (只要低字节)
        mov     bx,ax                   ; BX = n*24
        mov     byte ptr DGROUP:memo[bx],dl     ; memo[n][0] = n
        jmp     short @1@254            ; 跳到 done[n] = 1
@1@142:
;
;       fib(n - 1);
;
        mov     ax,word ptr [bp+4]
        dec     ax
        push    ax                      ; 实参入栈
        call    near ptr fib
        pop     cx                      ; 调用者清栈
;
;       fib(n - 2);
;
        mov     ax,word ptr [bp+4]
        add     ax,65534                ; AX = n - 2 (65534 = -2 的补码)
        push    ax
        call    near ptr fib
        pop     cx
;
;       for (i = 0; i < DIG; i++) {
;
        xor     si,si                   ; SI = i = 0
        jmp     short @1@226
@1@170:
;
;       t = memo[n-1][i] + memo[n-2][i] + carry;
;       地址: memo + (n-1)*24 + i = memo + n*24 + i - 24
;
        mov     ax,word ptr [bp+4]
        mov     dx,24
        imul    dx                      ; AX = n*24
        mov     bx,ax
        mov     al,byte ptr DGROUP:memo[bx+si-24]   ; memo[n-1][i]
        mov     ah,0
        push    ax                      ; 第一个操作数先压栈
        mov     ax,word ptr [bp+4]
        mov     dx,24
        imul    dx
        mov     bx,ax
        mov     al,byte ptr DGROUP:memo[bx+si-48]   ; memo[n-2][i]
        mov     ah,0
        pop     dx
        add     dx,ax                   ; + 第二个操作数
        add     dx,word ptr [bp-2]      ; + carry
        mov     di,dx                   ; DI = t
;
;       memo[n][i] = t % 10;
;
        mov     ax,di
        mov     bx,10
        xor     dx,dx
        div     bx                      ; DX = t % 10
        mov     ax,word ptr [bp+4]
        mov     bx,24
        push    dx                      ; 先保存余数
        imul    bx                      ; AX = n*24
        mov     bx,ax
        pop     ax
        mov     byte ptr DGROUP:memo[bx+si],al      ; memo[n][i]
;
;       carry = t / 10;
;
        mov     ax,di                   ; ★又做了一次除法: t/10
        mov     bx,10
        xor     dx,dx
        div     bx
        mov     word ptr [bp-2],ax      ; carry
        inc     si
@1@226:
        cmp     si,24                   ; i < DIG (24)
        jl      short @1@170
@1@254:
;
;       done[n] = 1;
;
        mov     bx,word ptr [bp+4]
        mov     byte ptr DGROUP:done[bx],1
@1@282:
        pop     di
        pop     si
        mov     sp,bp                   ; 释放局部变量
        pop     bp
        ret
fib     endp

;--------------------------------------------------------------
; int main(void)
;--------------------------------------------------------------
_main   proc    near
        push    bp
        mov     bp,sp
        sub     sp,2                    ; n 在 [bp-2]
        push    si                      ; i 放在 si
;
;       printf("n (1-100): ");
;
        mov     ax,offset DGROUP:s@
        push    ax
        call    near ptr _printf
        pop     cx
;
;       if (scanf("%d", &n) != 1)
;
        lea     ax,word ptr [bp-2]
        push    ax
        mov     ax,offset DGROUP:s@+12
        push    ax
        call    near ptr _scanf
        pop     cx
        pop     cx
        cmp     ax,1
        je      short @2@114
@2@58:
        mov     ax,1
@2@86:
        jmp     @2@590
@2@114:
;
;       if (n < 1 || n > MAXN)
;
        cmp     word ptr [bp-2],1
        jl      short @2@170
        cmp     word ptr [bp-2],100
        jle     short @2@198
@2@170:
        mov     ax,offset DGROUP:s@+15  ; "n must be 1..100\n"
        push    ax
        call    near ptr _printf
        pop     cx
        jmp     short @2@58
@2@198:
;
;       fib(n);
;
        push    word ptr [bp-2]
        call    near ptr fib
        pop     cx
;
;       i = DIG - 1; while (i > 0 && memo[n][i] == 0) i--;
;
        mov     si,23
        jmp     short @2@254
@2@226:
        dec     si
@2@254:
        or      si,si
        jle     short @2@310
        mov     ax,word ptr [bp-2]
        mov     dx,24
        imul    dx
        mov     bx,ax
        cmp     byte ptr DGROUP:memo[bx+si],0
        je      short @2@226
@2@310:
        jmp     short @2@450
@2@338:
;
;       for (; i >= 0; i--) putchar('0' + memo[n][i]);
;       TCC 对 putchar 做了优化: 缓冲区没满时直接写 __streams, 否则调 __fputc
;
        inc     word ptr DGROUP:__streams+16
        jge     short @2@394
        mov     ax,word ptr [bp-2]
        mov     dx,24
        imul    dx
        mov     bx,ax
        mov     al,byte ptr DGROUP:memo[bx+si]
        add     al,48                   ; '0'
        mov     bx,word ptr DGROUP:__streams+26
        inc     word ptr DGROUP:__streams+26
        mov     byte ptr [bx],al        ; 直接写缓冲区
        mov     ah,0
        jmp     short @2@422
@2@394:
        mov     ax,offset DGROUP:__streams+16
        push    ax
        mov     ax,word ptr [bp-2]
        mov     dx,24
        imul    dx
        mov     bx,ax
        mov     al,byte ptr DGROUP:memo[bx+si]
        add     al,48
        push    ax
        call    near ptr __fputc        ; 缓冲区满, 真正输出
        pop     cx
        pop     cx
@2@422:
        dec     si
@2@450:
        or      si,si
        jge     short @2@338
;
;       putchar('\n');
;
        inc     word ptr DGROUP:__streams+16
        jge     short @2@534
        mov     bx,word ptr DGROUP:__streams+26
        inc     word ptr DGROUP:__streams+26
        mov     al,10
        mov     byte ptr [bx],al
        mov     ah,0
        jmp     short @2@562
@2@534:
        mov     ax,offset DGROUP:__streams+16
        push    ax
        mov     al,10
        push    ax
        call    near ptr __fputc
        pop     cx
        pop     cx
@2@562:
        xor     ax,ax
        jmp     @2@86
@2@590:
        pop     si
        mov     sp,bp
        pop     bp
        ret
_main   endp

_TEXT   ends

;--------------------------------------------------------------
; 全局数组: 101 个 done 标志 + 101*24 字节 memo
;--------------------------------------------------------------
_BSS    segment word public 'BSS'
done    label   byte
        db      101 dup (?)
memo    label   byte
        db      2424 dup (?)
_BSS    ends

_DATA   segment word public 'DATA'
s@      label   byte
        db      'n (1-100): ',0
        db      '%d',0
        db      'n must be 1..100',10,0
_DATA   ends

        public  _main
_fib    equ     fib
_done   equ     done
_memo   equ     memo
        extrn   __fputc:near
        extrn   _scanf:near
        extrn   _printf:near
        extrn   __streams:word
_s@     equ     s@
        end
