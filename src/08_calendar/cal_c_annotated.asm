;==============================================================
; CAL_C_ANNOTATED.ASM
;   CALC.C 经 Turbo C++ 3.0 `TCC -ms -S CALC.C` 生成的反汇编,
;   下面是关键函数的逐段中文注释.
;
;   完整的原始输出见 evidence/08_calendar/CALC_GENERATED.ASM
;   (包含全部字符串和重复的 ?debug 行).
;
;   小模式 (-ms): 代码段 _TEXT, 数据段 DGROUP(_DATA/_BSS);
;   参数从右往左压栈, 所以第一个参数在 [bp+4], 第二个在 [bp+6].
;==============================================================

DGROUP  group   _DATA,_BSS
_TEXT   segment byte public 'CODE'
        assume cs:_TEXT, ds:DGROUP

;--------------------------------------------------------------
; int is_leap(int y)
;   帧: [bp+2]=返回地址  [bp+0]=旧BP  [bp-2]=保存的SI
;   参数: [bp+4] = y
;--------------------------------------------------------------
_is_leap proc near
        push    bp
        mov     bp,sp
        push    si
        mov     si,word ptr [bp+4]      ; SI = y

;   if (y % 4 != 0) return 0;
        mov     ax,si
        mov     bx,4
        cwd                             ; 把 AX 符号扩展到 DX:AX
        idiv    bx                      ; AX=商, DX=余数
        or      dx,dx                   ; 看余数是否为 0
        je      short @1@114
@1@58:
        xor     ax,ax                   ; return 0
@1@86:
        jmp     short @1@254

;   if (y % 100 != 0) return 1;
@1@114:
        mov     ax,si
        mov     bx,100
        cwd
        idiv    bx
        or      dx,dx
        je      short @1@170
        jmp     short @1@198

;   if (y % 400 == 0) return 1; else return 0;
@1@170:
        mov     ax,si
        mov     bx,400
        cwd
        idiv    bx
        or      dx,dx
        jne     short @1@226
@1@198:
        mov     ax,1                    ; return 1
        jmp     short @1@86
@1@226:
        jmp     short @1@58
@1@254:
        pop     si
        pop     bp
        ret
_is_leap endp

;--------------------------------------------------------------
; int days_in_month(int y, int m)
;   [bp+4]=y, [bp+6]=m
;--------------------------------------------------------------
_days_in_month proc near
        push    bp
        mov     bp,sp
        push    si
        mov     si,word ptr [bp+6]      ; SI = m

;   if (m == 2 && is_leap(y)) return 29;
        cmp     si,2
        jne     short @2@142
        push    word ptr [bp+4]         ; 压 y
        call    near ptr _is_leap
        pop     cx                      ; 调用者清栈
        or      ax,ax
        je      short @2@142
        mov     ax,29
@2@114:
        jmp     short @2@170

;   return mdays[m-1];
;   mdays 是 word 数组, 下标 m-1 的字节偏移 = 2*(m-1) = 2m-2
@2@142:
        mov     bx,si
        shl     bx,1                    ; BX = 2*m
        mov     ax,word ptr DGROUP:mdays[bx-2]
        jmp     short @2@114
@2@170:
        pop     si
        pop     bp
        ret
_days_in_month endp

;--------------------------------------------------------------
; int first_weekday(int y, int m)
;   局部变量 h 在 [bp-2]
;   [bp+4]=y, [bp+6]=m
;--------------------------------------------------------------
_first_weekday proc near
        push    bp
        mov     bp,sp
        sub     sp,2                    ; 给 h 留 2 字节
        push    si
        push    di
        mov     si,word ptr [bp+4]      ; SI = y
        mov     di,word ptr [bp+6]      ; DI = m

;   if (m < 3) { m += 12; y -= 1; }
        cmp     di,3
        jge     short @3@86
        add     di,12
        dec     si
@3@86:

;   h = (1 + 13*(m+1)/5 + y + y/4 - y/100 + y/400) % 7;
        mov     ax,di
        inc     ax                      ; AX = m+1
        mov     dx,13
        imul    dx                      ; DX:AX = 13*(m+1) (有符号乘)
        mov     bx,5
        cwd
        idiv    bx                      ; AX = 13*(m+1)/5
        add     ax,si                   ; + y
        push    ax                      ; 暂存中间结果
        mov     ax,si
        mov     bx,4
        cwd
        idiv    bx                      ; AX = y/4
        mov     dx,ax
        pop     ax
        add     ax,dx                   ; + y/4
        inc     ax                      ; + 1 (日)
        push    ax
        mov     ax,si
        mov     bx,100
        cwd
        idiv    bx                      ; AX = y/100
        mov     dx,ax
        pop     ax
        sub     ax,dx                   ; - y/100
        push    ax
        mov     ax,si
        mov     bx,400
        cwd
        idiv    bx                      ; AX = y/400
        mov     dx,ax
        pop     ax
        add     ax,dx                   ; + y/400
        mov     bx,7
        cwd
        idiv    bx                      ; DX = h
        mov     word ptr [bp-2],dx      ; 保存 h

;   return (h + 6) % 7;      ; 0=Sunday
        mov     ax,word ptr [bp-2]
        add     ax,6
        mov     bx,7
        cwd
        idiv    bx
        mov     ax,dx
        jmp     short @3@114
@3@114:
        pop     di
        pop     si
        mov     sp,bp                   ; 释放局部变量
        pop     bp
        ret
_first_weekday endp

;--------------------------------------------------------------
; void print_cal(int y, int m)
;   局部: [bp-2]=wd, [bp-4]=days
;   [bp+4]=y, [bp+6]=m
;--------------------------------------------------------------
_print_cal proc near
        push    bp
        mov     bp,sp
        sub     sp,4
        push    si
        push    di

;   wd = first_weekday(y, m);
        push    word ptr [bp+6]         ; 先压 m
        push    word ptr [bp+4]         ; 再压 y
        call    near ptr _first_weekday
        pop     cx
        pop     cx
        mov     word ptr [bp-2],ax      ; wd

;   days = days_in_month(y, m);
        push    word ptr [bp+6]
        push    word ptr [bp+4]
        call    near ptr _days_in_month
        pop     cx
        pop     cx
        mov     word ptr [bp-4],ax      ; days

;   printf("%d\n", y);    ; 变参: 参数从右往左压, 每个参数 pop 一次
        push    word ptr [bp+4]
        mov     ax,offset DGROUP:s@+86  ; "%d\n"
        push    ax
        call    near ptr _printf
        pop     cx
        pop     cx

;   printf("%s\n", mnames[m-1]);
        mov     bx,word ptr [bp+6]
        shl     bx,1                    ; 2*(m-1)
        push    word ptr DGROUP:mnames[bx-2]
        mov     ax,offset DGROUP:s@+90  ; "%s\n"
        push    ax
        call    near ptr _printf
        pop     cx
        pop     cx

;   printf("Su Mo Tu We Th Fr Sa\n");
        mov     ax,offset DGROUP:s@+94
        push    ax
        call    near ptr _printf
        pop     cx

;   for (d = 0; d < wd; d++) printf("   ");
        xor     si,si                   ; SI = d
        jmp     short @4@114
@4@58:
        mov     ax,offset DGROUP:s@+116 ; "   "
        push    ax
        call    near ptr _printf
        pop     cx
        inc     si
@4@114:
        cmp     si,word ptr [bp-2]
        jl      short @4@58

;   col = wd;  for (d = 1; d <= days; d++) { ... }
        mov     di,word ptr [bp-2]      ; DI = col
        mov     si,1                    ; SI = d
        jmp     short @4@310
@4@170:
;       printf("%2d", d);
        push    si
        mov     ax,offset DGROUP:s@+120 ; "%2d"
        push    ax
        call    near ptr _printf
        pop     cx
        pop     cx
;       col++;
        inc     di
;       if (col == 7) { printf("\n"); col = 0; }
        cmp     di,7
        jne     short @4@226
        mov     ax,offset DGROUP:s@+124 ; "\n"
        push    ax
        call    near ptr _printf
        pop     cx
        xor     di,di
        jmp     short @4@282
;       else if (d < days) printf(" ");
@4@226:
        cmp     si,word ptr [bp-4]
        jge     short @4@282
        mov     ax,offset DGROUP:s@+126 ; " "
        push    ax
        call    near ptr _printf
        pop     cx
@4@282:
        inc     si
@4@310:
        cmp     si,word ptr [bp-4]
        jle     short @4@170

;   if (col != 0) printf("\n");
        or      di,di
        je      short @4@394
        mov     ax,offset DGROUP:s@+128 ; "\n"
        push    ax
        call    near ptr _printf
        pop     cx
@4@394:
        pop     di
        pop     si
        mov     sp,bp
        pop     bp
        ret
_print_cal endp

;--------------------------------------------------------------
; int main(void)
;   局部: [bp-2]=y, [bp-4]=m
;--------------------------------------------------------------
_main proc near
        push    bp
        mov     bp,sp
        sub     sp,4
@5@30:
;   printf("input year (1900-2099): ");
        mov     ax,offset DGROUP:s@+130
        push    ax
        call    near ptr _printf
        pop     cx

;   if (scanf("%d", &y) != 1) return 1;
        lea     ax,word ptr [bp-2]      ; &y
        push    ax
        mov     ax,offset DGROUP:s@+155 ; "%d"
        push    ax
        call    near ptr _scanf
        pop     cx
        pop     cx
        cmp     ax,1
        je      short @5@114
@5@58:
        mov     ax,1
@5@86:
        jmp     short @5@478
@5@114:
;   if (y >= 1900 && y <= 2099) break;
        cmp     word ptr [bp-2],1900
        jl      short @5@198
        cmp     word ptr [bp-2],2099
        jg      short @5@198
        jmp     short @5@254
;   printf("year must be 1900-2099\n");
@5@198:
        mov     ax,offset DGROUP:s@+158
        push    ax
        call    near ptr _printf
        pop     cx
        jmp     short @5@30

@5@254:
;   printf("input month (1-12): ");
        mov     ax,offset DGROUP:s@+182
        push    ax
        call    near ptr _printf
        pop     cx
;   if (scanf("%d", &m) != 1) return 1;
        lea     ax,word ptr [bp-4]      ; &m
        push    ax
        mov     ax,offset DGROUP:s@+203 ; "%d"
        push    ax
        call    near ptr _scanf
        pop     cx
        pop     cx
        cmp     ax,1
        je      short @5@310
        jmp     short @5@58
@5@310:
;   if (m >= 1 && m <= 12) break;
        cmp     word ptr [bp-4],1
        jl      short @5@394
        cmp     word ptr [bp-4],12
        jg      short @5@394
        jmp     short @5@450
;   printf("month must be 1-12\n");
@5@394:
        mov     ax,offset DGROUP:s@+206
        push    ax
        call    near ptr _printf
        pop     cx
        jmp     short @5@254

@5@450:
;   print_cal(y, m);
        push    word ptr [bp-4]
        push    word ptr [bp-2]
        call    near ptr _print_cal
        pop     cx
        pop     cx
        xor     ax,ax                   ; return 0
        jmp     short @5@86
@5@478:
        mov     sp,bp
        pop     bp
        ret
_main endp

;--------------------------------------------------------------
; 数据段说明
;   完整定义见 CALC_GENERATED.ASM 末尾的 _DATA 段:
;     mdays  : 12 个 word (31,28,31,...)
;     mnames : 12 个 word, 指向 s@ 里的月份英文名
;     s@     : 所有字符串, 例如
;              s@+86  = "%d\n"
;              s@+90  = "%s\n"
;              s@+94  = "Su Mo Tu We Th Fr Sa\n"
;              s@+116 = "   "
;              s@+120 = "%2d"
;              s@+124 = "\n"
;              s@+126 = " "
;              s@+128 = "\n"
;              s@+130 = "input year (1900-2099): "
;              s@+155 = "%d"
;              s@+158 = "year must be 1900-2099\n"
;              s@+182 = "input month (1-12): "
;              s@+203 = "%d"
;              s@+206 = "month must be 1-12\n"
;--------------------------------------------------------------

        end
