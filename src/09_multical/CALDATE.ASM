;==============================================================
; CALDATE.ASM -- 日期计算模块
;
; 提供三个 PUBLIC 近过程:
;   is_leap_reg      AX=年 -> AL=1/0
;   month_days_reg   AX=年, BL=月 -> AX=天数
;   first_weekday_reg AX=年, CX=月 -> AL=0..6 (0=Sun)
;
; 本模块与 CALMAIN/CALDISP 使用同名的 CSEG 段,
; LINK 会把它们合并成一个物理代码段, 所以外部调用是 NEAR CALL.
;==============================================================

        .8086
        include CALMAC.INC

; 只声明 DATA 段名, 具体数据在 CALDATA.ASM 中定义
DGROUP  group   DATA
DATA    segment para public 'DATA'
DATA    ends

extrn  mdays:word

CSEG    segment para public 'CODE'
        assume cs:CSEG, ds:DGROUP

        public is_leap_reg, month_days_reg, first_weekday_reg

;--------------------------------------------------------------
; is_leap_reg : AX=年 -> AL=1/0
;--------------------------------------------------------------
is_leap_reg proc near
        PROLOG
        push bx
        push cx
        push dx

        mov  bx,ax
        mov  ax,bx
        xor  dx,dx
        mov  cx,4
        div  cx
        test dx,dx
        jnz  il_no

        mov  ax,bx
        xor  dx,dx
        mov  cx,100
        div  cx
        test dx,dx
        jnz  il_yes

        mov  ax,bx
        xor  dx,dx
        mov  cx,400
        div  cx
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
        EPILOG
is_leap_reg endp

;--------------------------------------------------------------
; month_days_reg : AX=年, BL=月 -> AX=天数
;--------------------------------------------------------------
month_days_reg proc near
        PROLOG
        push bx
        push cx
        push dx
        push si

        mov  si,ax
        mov  cl,bl
        xor  ch,ch

        mov  bx,offset mdays
        mov  ax,cx
        dec  ax
        shl  ax,1
        add  bx,ax
        mov  ax,[bx]

        cmp  cl,2
        jne  md_done
        mov  bx,ax
        mov  ax,si
        call is_leap_reg
        cmp  al,0
        je   md_keep
        inc  bx
md_keep:
        mov  ax,bx
md_done:
        pop  si
        pop  dx
        pop  cx
        pop  bx
        EPILOG
month_days_reg endp

;--------------------------------------------------------------
; first_weekday_reg : AX=年, CX=月 -> AL=0..6 (0=Sun)
;--------------------------------------------------------------
first_weekday_reg proc near
        PROLOG
        push bx
        push dx
        push si
        push di

        mov  si,ax
        mov  di,cx
        cmp  di,3
        jae  fw_m_ok
        add  di,12
        dec  si
fw_m_ok:
        mov  ax,di
        inc  ax
        mov  bx,13
        mul  bx
        mov  bx,5
        div  bx
        mov  bx,ax

        mov  ax,si
        add  bx,ax
        mov  ax,si
        xor  dx,dx
        mov  cx,4
        div  cx
        add  bx,ax
        mov  ax,si
        xor  dx,dx
        mov  cx,100
        div  cx
        sub  bx,ax
        mov  ax,si
        xor  dx,dx
        mov  cx,400
        div  cx
        add  bx,ax
        inc  bx

        mov  ax,bx
        xor  dx,dx
        mov  cx,7
        div  cx
        mov  ax,dx
        add  ax,6
        xor  dx,dx
        mov  cx,7
        div  cx
        mov  ax,dx

        pop  di
        pop  si
        pop  dx
        pop  bx
        EPILOG
first_weekday_reg endp

CSEG    ends

        end
