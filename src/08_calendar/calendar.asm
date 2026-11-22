;==============================================================
; CALENDAR.ASM  --  输出指定年份 (1900-2099) 和月份 (1-12) 的月历
;
; 环境 : DOSBox 0.74-3 + MASM 5.10 + LINK 3.64, 8086 16 位 DOS
;
; 结构 : 本程序刻意分成两个代码段, 用来练习段间调用:
;        CODE1 : 主程序、键盘输入、数值校验        (近过程)
;        CODE2 : 日期计算 + 月历显示               (远过程)
;
; 传参 : 三种方式都用到, 便于比较
;        (1) 寄存器 : AX=年, BL/CX=月, 返回 AX/AL
;        (2) 数据段 : cur_year / cur_month / cur_days / cur_wd
;        (3) 堆  栈 : 主程序 PUSH 年、月后远调用 show_calendar,
;                     被调过程用 [bp+8]/[bp+6] 取参数
;
; 算法 : Zeller 同余式求某月 1 日是星期几
;        m<3 时 m+=12, y-=1
;        h = (1 + 13*(m+1)/5 + y + y/4 - y/100 + y/400) mod 7
;        h: 0=Sat 1=Sun ... 6=Fri
;        再换成 0=Sun ... 6=Sat
;==============================================================

        .8086

;--------------------------------------------------------------
; 栈段: 256 字 = 512 字节. 本程序调用深度只有 2~3 层,
;       但 DOS 的 INT 21H 也要用栈, 所以留足余量.
;--------------------------------------------------------------
stackseg segment stack 'STACK'
        dw 256 dup(0)
stackseg ends

;--------------------------------------------------------------
; 数据段: 全局变量 + 提示信息 + 月份表
;--------------------------------------------------------------
dataseg segment para public 'DATA'
cur_year  dw 0                  ; 当前年份(数据段传参)
cur_month dw 0                  ; 当前月份
cur_days  dw 0                  ; 本月天数
cur_wd    dw 0                  ; 1 日的星期(0=Sun)

inbuf     db 6,0,6 dup(0)       ; INT 21H 0AH 缓冲: 最大6, 实际长度, 字符...

p_year    db 'input year (1900-2099): $'
p_month   db 'input month (1-12): $'
e_year    db 13,10,'year must be 1900-2099',13,10,'$'
e_month   db 13,10,'month must be 1-12',13,10,'$'

weekhdr   db 'Su Mo Tu We Th Fr Sa',13,10,'$'

mdays     dw 31,28,31,30,31,30,31,31,30,31,30,31
mnames    dw m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12
m1        db 'January$'
m2        db 'February$'
m3        db 'March$'
m4        db 'April$'
m5        db 'May$'
m6        db 'June$'
m7        db 'July$'
m8        db 'August$'
m9        db 'September$'
m10       db 'October$'
m11       db 'November$'
m12       db 'December$'
dataseg ends

;==============================================================
; 代码段 1 : 主程序 + 输入
;==============================================================
code1 segment para public 'CODE'
        assume cs:code1, ds:dataseg, ss:stackseg

start:
        mov ax,dataseg
        mov ds,ax

;---------------- 输入年份, 不合法就重输 ----------------
year_again:
        mov dx,offset p_year
        mov ah,9
        int 21h

        call read_dec               ; AX=数值, CF=1 表示非法
        jc year_bad
        cmp ax,1900
        jb year_bad
        cmp ax,2099
        ja year_bad
        mov cur_year,ax
        jmp month_again

year_bad:
        mov dx,offset e_year
        mov ah,9
        int 21h
        jmp year_again

;---------------- 输入月份, 不合法就重输 ----------------
month_again:
        mov dx,offset p_month
        mov ah,9
        int 21h

        call read_dec
        jc month_bad
        cmp ax,1
        jb month_bad
        cmp ax,12
        ja month_bad
        mov cur_month,ax
        jmp show

month_bad:
        mov dx,offset e_month
        mov ah,9
        int 21h
        jmp month_again

;---------------- 栈传参 + 段间远调用 ----------------
show:
        mov ax,cur_year
        push ax                     ; 参数1: 年
        mov ax,cur_month
        push ax                     ; 参数2: 月
        call far ptr show_calendar  ; 机器码 9A, 进入 CODE2
        add sp,4                    ; 调用者清栈

        mov ax,4c00h
        int 21h

;--------------------------------------------------------------
; read_dec : 读一行十进制数 -> AX
;            出口: CF=0 正常, CF=1 含非法字符
;            用寄存器传参/返回, 内部保护 BX/CX/DX/SI
;--------------------------------------------------------------
read_dec proc
        push bx
        push cx
        push dx
        push si

        mov dx,offset inbuf
        mov ah,0ah                  ; 缓冲输入
        int 21h

        mov dl,13                   ; 0AH 不回显换行, 自己补一个
        mov ah,2
        int 21h
        mov dl,10
        mov ah,2
        int 21h

        mov cl,[inbuf+1]            ; 实际字符数
        xor ch,ch
        mov si,offset inbuf         ; 字符从 inbuf+2 开始
        add si,2
        xor ax,ax                   ; AX=累加值
        xor bx,bx

rd_loop:
        jcxz rd_ok
        mov bl,[si]
        cmp bl,13                   ; 0AH 会把回车也存进来
        je rd_ok
        sub bl,'0'
        cmp bl,9
        ja rd_bad                   ; 非数字
        mov dx,10
        mul dx                      ; AX = AX*10 (结果 < 65536)
        add ax,bx
        inc si
        dec cx
        jmp rd_loop

rd_ok:
        clc
        jmp rd_exit
rd_bad:
        stc
rd_exit:
        pop si
        pop dx
        pop cx
        pop bx
        ret
read_dec endp

code1 ends

;==============================================================
; 代码段 2 : 日期计算 + 显示
;    所有过程都在本段内近调用; 只有 CODE1 用 FAR CALL 进来.
;==============================================================
code2 segment para public 'CODE'
        assume cs:code2, ds:dataseg, ss:stackseg

;--------------------------------------------------------------
; show_calendar : 远过程, 参数在栈上
;                 远调用栈帧: [bp+2]=返回IP [bp+4]=返回CS
;                             [bp+6]=月   [bp+8]=年
;--------------------------------------------------------------
show_calendar proc far
        push bp
        mov  bp,sp
        push ax
        push bx
        push cx
        push dx
        push si
        push di

        mov  ax,[bp+8]              ; 年
        mov  cur_year,ax
        mov  ax,[bp+6]              ; 月
        mov  cur_month,ax

        call print_year
        call print_month_name
        call print_week_header
        call print_grid

        pop  di
        pop  si
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        pop  bp
        ret                         ; FAR 过程 -> RETF (CB)
show_calendar endp

;--------------------------------------------------------------
; is_leap_reg : AX=年 -> AL=1/0
;--------------------------------------------------------------
is_leap_reg proc
        push bx
        push cx
        push dx

        mov  bx,ax
        mov  ax,bx
        xor  dx,dx
        mov  cx,4
        div  cx                     ; DX = year % 4
        test dx,dx
        jnz  il_no

        mov  ax,bx
        xor  dx,dx
        mov  cx,100
        div  cx                     ; DX = year % 100
        test dx,dx
        jnz  il_yes

        mov  ax,bx
        xor  dx,dx
        mov  cx,400
        div  cx                     ; DX = year % 400
        test dx,dx
        jnz  il_no
il_yes:
        mov  al,1
        jmp  il_done
il_no:
        xor  al,al
il_done:
        pop  dx
        pop  cx
        pop  bx
        ret
is_leap_reg endp

;--------------------------------------------------------------
; month_days_reg : 寄存器传参 AX=年, BL=月 -> AX=天数
;--------------------------------------------------------------
month_days_reg proc
        push bx
        push cx
        push dx
        push si

        mov  si,ax                  ; SI = 年
        mov  cl,bl                  ; CL = 月
        xor  ch,ch

        mov  bx,offset mdays
        mov  ax,cx
        dec  ax
        shl  ax,1                   ; (月-1)*2
        add  bx,ax
        mov  ax,[bx]                ; 28/30/31

        cmp  cl,2
        jne  md_done
        mov  bx,ax                  ; 先存 28
        mov  ax,si
        call is_leap_reg            ; AX=年 -> AL
        cmp  al,0
        je   md_keep
        inc  bx                     ; 闰年 2 月 = 29
md_keep:
        mov  ax,bx
md_done:
        pop  si
        pop  dx
        pop  cx
        pop  bx
        ret
month_days_reg endp

;--------------------------------------------------------------
; first_weekday_reg : 寄存器传参 AX=年, CX=月 -> AL=星期(0=Sun)
;                     Zeller 同余式, 只用 16 位加减乘除
;--------------------------------------------------------------
first_weekday_reg proc
        push bx
        push dx
        push si
        push di

        mov  si,ax                  ; SI = y
        mov  di,cx                  ; DI = m
        cmp  di,3
        jae  fw_m_ok
        add  di,12                  ; 1、2 月看作上一年的 13、14 月
        dec  si
fw_m_ok:
        mov  ax,di
        inc  ax
        mov  bx,13
        mul  bx                     ; DX:AX = 13*(m+1)
        mov  bx,5
        div  bx                     ; AX = 13*(m+1)/5
        mov  bx,ax                  ; BX = 第一项

        mov  ax,si
        add  bx,ax                  ; + y
        mov  ax,si
        xor  dx,dx
        mov  cx,4
        div  cx
        add  bx,ax                  ; + y/4
        mov  ax,si
        xor  dx,dx
        mov  cx,100
        div  cx
        sub  bx,ax                  ; - y/100
        mov  ax,si
        xor  dx,dx
        mov  cx,400
        div  cx
        add  bx,ax                  ; + y/400
        inc  bx                     ; + day(=1)

        mov  ax,bx
        xor  dx,dx
        mov  cx,7
        div  cx                     ; DX = h
        mov  ax,dx
        add  ax,6                   ; 0=Sun: w=(h+6)%7
        xor  dx,dx
        mov  cx,7
        div  cx
        mov  ax,dx

        pop  di
        pop  si
        pop  dx
        pop  bx
        ret
first_weekday_reg endp

;--------------------------------------------------------------
; print_year : 输出 4 位年份 + 换行
;--------------------------------------------------------------
print_year proc
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
        call newline

        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
print_year endp

;--------------------------------------------------------------
; print_month_name : 用数据段偏移表取月份英文名
;--------------------------------------------------------------
print_month_name proc
        push ax
        push bx
        push dx

        mov  bx,cur_month
        dec  bx
        shl  bx,1
        mov  dx,[mnames+bx]
        mov  ah,9
        int  21h
        call newline

        pop  dx
        pop  bx
        pop  ax
        ret
print_month_name endp

;--------------------------------------------------------------
; print_week_header
;--------------------------------------------------------------
print_week_header proc
        push ax
        push dx
        mov  dx,offset weekhdr
        mov  ah,9
        int  21h
        pop  dx
        pop  ax
        ret
print_week_header endp

;--------------------------------------------------------------
; print_grid : 读数据段全局变量, 调寄存器传参的日期过程
;              每格宽 2 字符, 格间 1 个空格, 与题面样例一致
;--------------------------------------------------------------
print_grid proc
        push ax
        push bx
        push cx
        push dx
        push si
        push di

        mov  ax,cur_year
        mov  bl,byte ptr cur_month
        call month_days_reg         ; AX = 本月天数
        mov  di,ax                  ; DI = days
        mov  cur_days,ax

        mov  ax,cur_year
        mov  cx,cur_month
        call first_weekday_reg      ; AL = 星期
        xor  ah,ah
        mov  cur_wd,ax
        mov  si,ax                  ; SI = 当前列 0..6

;---- 1 日之前的空格: 每个空单元格 3 个空格 ----
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

;---- 逐日输出 ----
pg_days:
        mov  bx,1                   ; BX = day
pg_loop:
        mov  ax,bx
        call putdec2                ; 输出 2 位, 1..9 前补空格

        cmp  bx,di
        jae  pg_last                ; 最后一天

        cmp  si,6
        jne  pg_space
        call newline                ; 星期六后换行
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
        call newline

        pop  di
        pop  si
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
print_grid endp

;--------------------------------------------------------------
; putdec2 : AX(0..31) 输出成 2 位, 不足两位前补空格
;--------------------------------------------------------------
putdec2 proc
        push ax
        push bx
        push dx

        mov  bx,10
        xor  dx,dx
        div  bx                     ; AX=十位, DX=个位
        push dx                     ; 保存个位
        cmp  ax,0
        jne  pd_tens
        mov  dl,' '                 ; 0~9: 十位打空格
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
putchar proc
        push ax
        mov  dl,al
        mov  ah,2
        int  21h
        pop  ax
        ret
putchar endp

;--------------------------------------------------------------
; newline : CR LF
;--------------------------------------------------------------
newline proc
        push ax
        push dx
        mov  dl,13
        mov  ah,2
        int  21h
        mov  dl,10
        mov  ah,2
        int  21h
        pop  dx
        pop  ax
        ret
newline endp

code2 ends
        end start
