;==============================================================
; CALDATA.ASM -- 多模块日历的公共数据段
;
; 本模块只定义数据和 PUBLIC 符号, 不产生代码.
; 其他模块用 EXTRN 引用这里的变量/字符串.
;==============================================================

        .8086

DGROUP  group   DATA
DATA    segment para public 'DATA'

        public cur_year, cur_month, cur_days, cur_wd
        public inbuf
        public p_year, p_month, e_year, e_month
        public weekhdr
        public mdays, mnames

cur_year  dw 0
cur_month dw 0
cur_days  dw 0
cur_wd    dw 0

inbuf     db 6,0,6 dup(0)

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

DATA    ends

        end
