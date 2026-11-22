;==============================================================
; CALMAIN.ASM -- 多模块日历的主程序
;
; 模块划分:
;   CALMAIN.ASM : 主程序、键盘输入、范围校验
;   CALDATE.ASM : 闰年/月天数/星期计算
;   CALDISP.ASM : 月历显示
;   CALDATA.ASM : 公共数据段
;   CALMAC.INC  : 宏定义
;
; 三个代码模块都使用同名 CSEG 段, LINK 合并成一个物理代码段,
; 因此 main -> show_calendar 是 NEAR CALL (E8), 不换 CS.
;==============================================================

        .8086
        include CALMAC.INC

STACK   segment stack 'STACK'
        dw 256 dup(0)
STACK   ends

; 只声明 DATA 段名, 具体数据在 CALDATA.ASM 中定义
DGROUP  group   DATA
DATA    segment para public 'DATA'
DATA    ends

extrn  show_calendar:near
        extrn  cur_year:word, cur_month:word
        extrn  inbuf:byte
        extrn  p_year:byte, p_month:byte, e_year:byte, e_month:byte

CSEG    segment para public 'CODE'
        assume cs:CSEG, ds:DGROUP, ss:STACK



start:
        mov  ax,DGROUP
        mov  ds,ax

;---------------- 输入年份 ----------------
year_again:
        PRINTSTR p_year
        call read_dec
        jc   year_bad
        cmp  ax,1900
        jb   year_bad
        cmp  ax,2099
        ja   year_bad
        mov  cur_year,ax
        jmp  month_again

year_bad:
        PRINTSTR e_year
        jmp  year_again

;---------------- 输入月份 ----------------
month_again:
        PRINTSTR p_month
        call read_dec
        jc   month_bad
        cmp  ax,1
        jb   month_bad
        cmp  ax,12
        ja   month_bad
        mov  cur_month,ax
        jmp  show

month_bad:
        PRINTSTR e_month
        jmp  month_again

;---------------- 近调用显示模块 ----------------
show:
        push cur_year
        push cur_month
        call show_calendar          ; 外部近过程 -> E8, 不换 CS
        add  sp,4

        mov  ax,4c00h
        int  21h

;--------------------------------------------------------------
; read_dec : 读一行十进制数 -> AX; CF=1 表示非法
;--------------------------------------------------------------
read_dec proc near
        PROLOG
        push bx
        push cx
        push dx
        push si

        mov  dx,offset inbuf
        mov  ah,0ah
        int  21h
        NEWLINE

        mov  cl,[inbuf+1]
        xor  ch,ch
        mov  si,offset inbuf
        add  si,2
        xor  ax,ax
        xor  bx,bx

rd_loop:
        jcxz rd_ok
        mov  bl,[si]
        cmp  bl,13
        je   rd_ok
        sub  bl,'0'
        cmp  bl,9
        ja   rd_bad
        mov  dx,10
        mul  dx
        add  ax,bx
        inc  si
        dec  cx
        jmp  rd_loop

rd_ok:
        clc
        jmp  rd_exit
rd_bad:
        stc
rd_exit:
        pop  si
        pop  dx
        pop  cx
        pop  bx
        EPILOG
read_dec endp

CSEG    ends

        end start
