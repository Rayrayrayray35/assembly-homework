;==============================================================
; CALDISP.ASM -- 月历显示模块
;
; 提供 PUBLIC 近过程 show_calendar:
;   入口参数在栈上: [bp+4]=年, [bp+6]=月 (近调用)
;   内部用宏 PRINTSTR/NEWLINE/SAVEREGS/RESTOREREGS.
;
; 本模块与 CALMAIN/CALDATE 使用同名 CSEG 段, LINK 合并后
; show_calendar 与 main 在同一个物理代码段, 所以 call 是 NEAR.
;==============================================================

        .8086
        include CALMAC.INC

; 只声明 DATA 段名, 具体数据在 CALDATA.ASM 中定义
DGROUP  group   DATA
DATA    segment para public 'DATA'
DATA    ends

extrn  cur_year:word, cur_month:word, cur_days:word, cur_wd:word
extrn  weekhdr:byte, mnames:word
extrn  month_days_reg:near, first_weekday_reg:near

CSEG    segment para public 'CODE'
        assume cs:CSEG, ds:DGROUP

        public show_calendar

;--------------------------------------------------------------
; show_calendar : 近过程, 参数 [bp+6]=年, [bp+4]=月
;   近调用栈帧: [bp+2]=返回IP, [bp+4]=最后压的月, [bp+6]=先压的年
;--------------------------------------------------------------
show_calendar proc near
        PROLOG
        SAVEREGS

        mov  ax,[bp+6]              ; 年 (近调用: [bp+6]=先压的年)
        mov  cur_year,ax
        mov  ax,[bp+4]              ; 月 (最后压的在 [bp+4])
        mov  cur_month,ax

        call print_year
        call print_month_name
        call print_week_header
        call print_grid

        RESTOREREGS
        pop  bp
        ret
show_calendar endp

;--------------------------------------------------------------
; print_year : 输出 4 位年份 + 换行
;--------------------------------------------------------------
print_year proc near
        push ax
        push bx
        push cx
        push dx

        mov  ax,cur_year
        mov  cx,1000
        xor  dx,dx
        div  cx
        mov  bx,dx
        add  al,'0'
        call putchar

        mov  ax,bx
        mov  cx,100
        xor  dx,dx
        div  cx
        mov  bx,dx
        add  al,'0'
        call putchar

        mov  ax,bx
        mov  cx,10
        xor  dx,dx
        div  cx
        mov  bx,dx
        add  al,'0'
        call putchar

        mov  ax,bx
        add  al,'0'
        call putchar
        call put_nl

        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
print_year endp

;--------------------------------------------------------------
; print_month_name : 用 mnames 偏移表取英文月份名
;--------------------------------------------------------------
print_month_name proc near
        push ax
        push bx
        push dx

        mov  bx,cur_month
        dec  bx
        shl  bx,1
        mov  dx,[mnames+bx]
        mov  ah,9
        int  21h
        call put_nl

        pop  dx
        pop  bx
        pop  ax
        ret
print_month_name endp

;--------------------------------------------------------------
; print_week_header : 用宏输出表头
;--------------------------------------------------------------
print_week_header proc near
        PRINTSTR weekhdr
        ret
print_week_header endp

;--------------------------------------------------------------
; print_grid : 输出日期网格
;--------------------------------------------------------------
print_grid proc near
        push ax
        push bx
        push cx
        push dx
        push si
        push di

        mov  ax,cur_year
        mov  bl,byte ptr cur_month
        call month_days_reg         ; AX = 天数
        mov  di,ax
        mov  cur_days,ax

        mov  ax,cur_year
        mov  cx,cur_month
        call first_weekday_reg      ; AL = 星期
        xor  ah,ah
        mov  cur_wd,ax
        mov  si,ax                  ; SI = 列

        mov  cx,si
        jcxz pg_days
pg_lead:
        mov  al,' '
        call putchar
        mov  al,' '
        call putchar
        mov  al,' '
        call putchar
        loop pg_lead

pg_days:
        mov  bx,1                   ; BX = 日
pg_loop:
        mov  ax,bx
        call putdec2

        cmp  bx,di
        jae  pg_last

        cmp  si,6
        jne  pg_space
        call put_nl
        xor  si,si
        jmp  pg_next
pg_space:
        mov  al,' '
        call putchar
        inc  si
pg_next:
        inc  bx
        jmp  pg_loop

pg_last:
        call put_nl

        pop  di
        pop  si
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
print_grid endp

;--------------------------------------------------------------
; putdec2 : AX(0..31) -> 2 位, 不足两位前补空格
;--------------------------------------------------------------
putdec2 proc near
        push ax
        push bx
        push dx

        mov  bx,10
        xor  dx,dx
        div  bx
        push dx
        cmp  ax,0
        jne  pd_tens
        mov  dl,' '
        jmp  pd_out1
pd_tens:
        mov  dl,al
        add  dl,'0'
pd_out1:
        mov  ah,2
        int  21h

        pop  dx
        add  dl,'0'
        mov  ah,2
        int  21h

        pop  dx
        pop  bx
        pop  ax
        ret
putdec2 endp

;--------------------------------------------------------------
; putchar : AL 中的字符输出
;--------------------------------------------------------------
putchar proc near
        push ax
        mov  dl,al
        mov  ah,2
        int  21h
        pop  ax
        ret
putchar endp

;--------------------------------------------------------------
; newline : 用 NEWLINE 宏展开
;--------------------------------------------------------------
put_nl proc near
        NEWLINE
        ret
put_nl endp

CSEG    ends

        end
