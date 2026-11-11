; ==============================================================
; fib_c_annotated.asm
;   Turbo C++ 3.0  `TCC -ms -S FIB.C` 生成的汇编(大模式 -ms),
;   删去编译器自带的 ?debug 宏与调试信息, 逐条加中文注释.
;
; 重点看 _fib:
;   1) 递归函数的栈帧: push bp / mov bp,sp / push si
;   2) 参数在 [bp+4]: call 先压 2 字节返回地址, 再上面 2 字节是实参
;   3) 32 位返回值放 DX:AX, 相加要用 add + adc
;   4) 递归调用前后用 push/pop 保存中间结果, 这些字节都占栈
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
; unsigned long fib(unsigned n)
;
; 栈帧(每层):
;       [bp+4] 参数 n            <- 调用者 PUSH 进来的实参
;       [bp+2] 返回地址
;       [bp+0] 调用者的 bp
;       [bp-2] 保存的 si         <- si 里放着 n (寄存器变量)
;   即: 进入函数时 SP 比调用者的 SP 低 4 字节(返回地址+参数),
;       再加上 push bp / push si 的 4 字节, 每层共 8 字节.
;--------------------------------------------------------------
_fib    proc    near
        push    bp              ; 保存调用者的 bp
        mov     bp,sp           ; bp = 本层栈帧基址
        push    si              ; TCC 约定: si/di 由被调函数保存
        mov     si,word ptr [bp+4]      ; SI = n
;
;       if (n < 2)
;
        cmp     si,2
        jae     short @1@86     ; n >= 2 -> 递归分支
;
;       return n;               ; 返回值是 unsigned long, 放 DX:AX
;
        mov     ax,si           ; AX = 低 16 位 = n
        xor     dx,dx           ; DX = 高 16 位 = 0
        jmp     short @1@114
@1@86:
;
;       return fib(n - 1) + fib(n - 2);
;
        mov     ax,si
        dec     ax              ; AX = n-1
        push    ax              ; 实参入栈
        call    near ptr _fib   ; 递归调用
        pop     cx              ; 调用者清栈(cdecl: 参数由调用者弹出)
        push    ax              ; ★把 F(n-1) 的低 16 位压栈保存
        push    dx              ; ★高 16 位也压栈保存 (共 4 字节)
        mov     ax,si
        sub     ax,2            ; AX = n-2
        push    ax
        call    near ptr _fib   ; 第二次递归
        pop     cx
        mov     bx,dx           ; BX = F(n-2) 高 16 位
        pop     dx              ; DX = F(n-1) 高 16 位
        pop     cx              ; CX = F(n-1) 低 16 位
        add     cx,ax           ; 低 16 位相加
        adc     dx,bx           ; 高 16 位带进位加 -> DX:AX
        mov     ax,cx
        jmp     short @1@114
@1@114:
        pop     si              ; 恢复 si
        pop     bp              ; 恢复 bp, 栈帧消失
        ret                     ; 返回 (只弹出返回地址, 参数由调用者弹)
_fib    endp

;--------------------------------------------------------------
; int main(void)
;--------------------------------------------------------------
_main   proc    near
        push    bp
        mov     bp,sp
        sub     sp,2            ; 局部变量 n 在 [bp-2]
;
;       printf("n (1-40): ");
;
        mov     ax,offset DGROUP:s@
        push    ax
        call    near ptr _printf
        pop     cx              ; printf 只有一个参数, 弹 2 字节
;
;       if (scanf("%u", &n) != 1)
;
        lea     ax,word ptr [bp-2]      ; &n
        push    ax
        mov     ax,offset DGROUP:s@+11  ; "%u"
        push    ax
        call    near ptr _scanf
        pop     cx
        pop     cx              ; 两个参数分两次弹出
        cmp     ax,1
        je      short @2@114
        mov     ax,1            ; return 1;
@2@86:
        jmp     short @2@142
@2@114:
;
;       printf("F(%u) = %lu\n", n, fib(n));
;       压参顺序: 从右往左 -> fib(n) 的结果、n、格式串
;
        push    word ptr [bp-2]         ; 实参 n
        call    near ptr _fib
        pop     cx
        push    dx              ; 先压 32 位结果的高位
        push    ax              ; 再压低 16 位
        push    word ptr [bp-2] ; n
        mov     ax,offset DGROUP:s@+14  ; "F(%u) = %lu\n"
        push    ax
        call    near ptr _printf
        add     sp,8            ; 4 个参数共 8 字节, 一次清栈
;
;       return 0;
;
        xor     ax,ax
        jmp     short @2@86
@2@142:
        mov     sp,bp           ; 释放局部变量
        pop     bp
        ret
_main   endp

_TEXT   ends

;--------------------------------------------------------------
; 字符串常量
;--------------------------------------------------------------
_DATA   segment word public 'DATA'
s@      label   byte
        db      'n (1-40): ',0
        db      '%u',0
        db      'F(%u) = %lu',10,0
_DATA   ends

        public  _main
        public  _fib
        extrn   _scanf:near
        extrn   _printf:near
_s@     equ     s@
        end
