	ifndef	??version
?debug	macro
	endm
$comm	macro	name,dist,size,count
	comm	dist name:BYTE:count*size
	endm
	else
$comm	macro	name,dist,size,count
	comm	dist name[size]:BYTE:count
	endm
	endif
	?debug	S "calc.c"
	?debug	C E9CB8B765D0663616C632E63
	?debug	C E990984F561A433A5C545552424F43335C494E434C5544455C7374+
	?debug	C 64696F2E68
	?debug	C E990984F561A433A5C545552424F43335C494E434C5544455C5F64+
	?debug	C 6566732E68
	?debug	C E990984F561A433A5C545552424F43335C494E434C5544455C5F6E+
	?debug	C 756C6C2E68
_TEXT	segment byte public 'CODE'
_TEXT	ends
DGROUP	group	_DATA,_BSS
	assume	cs:_TEXT,ds:DGROUP
_DATA	segment word public 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends
_DATA	segment word public 'DATA'
mdays	label	word
	db	31
	db	0
	db	28
	db	0
	db	31
	db	0
	db	30
	db	0
	db	31
	db	0
	db	30
	db	0
	db	31
	db	0
	db	31
	db	0
	db	30
	db	0
	db	31
	db	0
	db	30
	db	0
	db	31
	db	0
mnames	label	word
	dw	DGROUP:s@
	dw	DGROUP:s@+8
	dw	DGROUP:s@+17
	dw	DGROUP:s@+23
	dw	DGROUP:s@+29
	dw	DGROUP:s@+33
	dw	DGROUP:s@+38
	dw	DGROUP:s@+43
	dw	DGROUP:s@+50
	dw	DGROUP:s@+60
	dw	DGROUP:s@+68
	dw	DGROUP:s@+77
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	int is_leap(int y)
   ;	
	assume	cs:_TEXT
_is_leap	proc	near
	push	bp
	mov	bp,sp
	push	si
	mov	si,word ptr [bp+4]
   ;	
   ;	{
   ;	    if (y % 4 != 0)
   ;	
	mov	ax,si
	mov	bx,4
	cwd	
	idiv	bx
	or	dx,dx
	je	short @1@114
@1@58:
   ;	
   ;	        return 0;
   ;	
	xor	ax,ax
@1@86:
	jmp	short @1@254
@1@114:
   ;	
   ;	    if (y % 100 != 0)
   ;	
	mov	ax,si
	mov	bx,100
	cwd	
	idiv	bx
	or	dx,dx
	je	short @1@170
	jmp	short @1@198
@1@170:
   ;	
   ;	        return 1;
   ;	    if (y % 400 == 0)
   ;	
	mov	ax,si
	mov	bx,400
	cwd	
	idiv	bx
	or	dx,dx
	jne	short @1@226
@1@198:
   ;	
   ;	        return 1;
   ;	
	mov	ax,1
	jmp	short @1@86
@1@226:
	jmp	short @1@58
@1@254:
   ;	
   ;	    return 0;
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_is_leap	endp
   ;	
   ;	int days_in_month(int y, int m)
   ;	
	assume	cs:_TEXT
_days_in_month	proc	near
	push	bp
	mov	bp,sp
	push	si
	mov	si,word ptr [bp+6]
   ;	
   ;	{
   ;	    if (m == 2 && is_leap(y))
   ;	
	cmp	si,2
	jne	short @2@142
	push	word ptr [bp+4]
	call	near ptr _is_leap
	pop	cx
	or	ax,ax
	je	short @2@142
   ;	
   ;	        return 29;
   ;	
	mov	ax,29
@2@114:
	jmp	short @2@170
@2@142:
   ;	
   ;	    return mdays[m - 1];
   ;	
	mov	bx,si
	shl	bx,1
	mov	ax,word ptr DGROUP:mdays[bx-2]
	jmp	short @2@114
@2@170:
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_days_in_month	endp
   ;	
   ;	int first_weekday(int y, int m)
   ;	
	assume	cs:_TEXT
_first_weekday	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
	push	di
	mov	si,word ptr [bp+4]
	mov	di,word ptr [bp+6]
   ;	
   ;	{
   ;	    int h;
   ;	
   ;	    if (m < 3) {
   ;	
	cmp	di,3
	jge	short @3@86
   ;	
   ;	        m += 12;
   ;	
	add	di,12
   ;	
   ;	        y -= 1;
   ;	
	dec	si
@3@86:
   ;	
   ;	    }
   ;	    h = (1 + 13 * (m + 1) / 5 + y + y / 4 - y / 100 + y / 400) % 7;
   ;	
	mov	ax,di
	inc	ax
	mov	dx,13
	imul	dx
	mov	bx,5
	cwd	
	idiv	bx
	add	ax,si
	push	ax
	mov	ax,si
	mov	bx,4
	cwd	
	idiv	bx
	mov	dx,ax
	pop	ax
	add	ax,dx
	inc	ax
	push	ax
	mov	ax,si
	mov	bx,100
	cwd	
	idiv	bx
	mov	dx,ax
	pop	ax
	sub	ax,dx
	push	ax
	mov	ax,si
	mov	bx,400
	cwd	
	idiv	bx
	mov	dx,ax
	pop	ax
	add	ax,dx
	mov	bx,7
	cwd	
	idiv	bx
	mov	word ptr [bp-2],dx
   ;	
   ;	    return (h + 6) % 7;
   ;	
	mov	ax,word ptr [bp-2]
	add	ax,6
	mov	bx,7
	cwd	
	idiv	bx
	mov	ax,dx
	jmp	short @3@114
@3@114:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_first_weekday	endp
   ;	
   ;	void print_cal(int y, int m)
   ;	
	assume	cs:_TEXT
_print_cal	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
	push	di
   ;	
   ;	{
   ;	    int wd, days, d, col;
   ;	
   ;	    wd   = first_weekday(y, m);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	call	near ptr _first_weekday
	pop	cx
	pop	cx
	mov	word ptr [bp-2],ax
   ;	
   ;	    days = days_in_month(y, m);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	call	near ptr _days_in_month
	pop	cx
	pop	cx
	mov	word ptr [bp-4],ax
   ;	
   ;	
   ;	    printf("%d\n", y);
   ;	
	push	word ptr [bp+4]
	mov	ax,offset DGROUP:s@+86
	push	ax
	call	near ptr _printf
	pop	cx
	pop	cx
   ;	
   ;	    printf("%s\n", mnames[m - 1]);
   ;	
	mov	bx,word ptr [bp+6]
	shl	bx,1
	push	word ptr DGROUP:mnames[bx-2]
	mov	ax,offset DGROUP:s@+90
	push	ax
	call	near ptr _printf
	pop	cx
	pop	cx
   ;	
   ;	    printf("Su Mo Tu We Th Fr Sa\n");
   ;	
	mov	ax,offset DGROUP:s@+94
	push	ax
	call	near ptr _printf
	pop	cx
   ;	
   ;	
   ;	    for (d = 0; d < wd; d++)
   ;	
	xor	si,si
	jmp	short @4@114
@4@58:
   ;	
   ;	        printf("   ");
   ;	
	mov	ax,offset DGROUP:s@+116
	push	ax
	call	near ptr _printf
	pop	cx
	inc	si
@4@114:
	cmp	si,word ptr [bp-2]
	jl	short @4@58
   ;	
   ;	
   ;	    col = wd;
   ;	
	mov	di,word ptr [bp-2]
   ;	
   ;	    for (d = 1; d <= days; d++) {
   ;	
	mov	si,1
	jmp	short @4@310
@4@170:
   ;	
   ;	        printf("%2d", d);
   ;	
	push	si
	mov	ax,offset DGROUP:s@+120
	push	ax
	call	near ptr _printf
	pop	cx
	pop	cx
   ;	
   ;	        col++;
   ;	
	inc	di
   ;	
   ;	        if (col == 7) {
   ;	
	cmp	di,7
	jne	short @4@226
   ;	
   ;	            printf("\n");
   ;	
	mov	ax,offset DGROUP:s@+124
	push	ax
	call	near ptr _printf
	pop	cx
   ;	
   ;	            col = 0;
   ;	
	xor	di,di
   ;	
   ;	        } else if (d < days) {
   ;	
	jmp	short @4@282
@4@226:
	cmp	si,word ptr [bp-4]
	jge	short @4@282
   ;	
   ;	            printf(" ");
   ;	
	mov	ax,offset DGROUP:s@+126
	push	ax
	call	near ptr _printf
	pop	cx
@4@282:
	inc	si
@4@310:
	cmp	si,word ptr [bp-4]
	jle	short @4@170
   ;	
   ;	        }
   ;	    }
   ;	    if (col != 0)
   ;	
	or	di,di
	je	short @4@394
   ;	
   ;	        printf("\n");
   ;	
	mov	ax,offset DGROUP:s@+128
	push	ax
	call	near ptr _printf
	pop	cx
@4@394:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_print_cal	endp
   ;	
   ;	int main(void)
   ;	
	assume	cs:_TEXT
_main	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
@5@30:
   ;	
   ;	{
   ;	    int y, m;
   ;	
   ;	    for (;;) {
   ;	        printf("input year (1900-2099): ");
   ;	
	mov	ax,offset DGROUP:s@+130
	push	ax
	call	near ptr _printf
	pop	cx
   ;	
   ;	        if (scanf("%d", &y) != 1)
   ;	
	lea	ax,word ptr [bp-2]
	push	ax
	mov	ax,offset DGROUP:s@+155
	push	ax
	call	near ptr _scanf
	pop	cx
	pop	cx
	cmp	ax,1
	je	short @5@114
@5@58:
   ;	
   ;	            return 1;
   ;	
	mov	ax,1
@5@86:
	jmp	short @5@478
@5@114:
   ;	
   ;	        if (y >= 1900 && y <= 2099)
   ;	
	cmp	word ptr [bp-2],1900
	jl	short @5@198
	cmp	word ptr [bp-2],2099
	jg	short @5@198
   ;	
   ;	            break;
   ;	
	jmp	short @5@254
@5@198:
   ;	
   ;	        printf("year must be 1900-2099\n");
   ;	
	mov	ax,offset DGROUP:s@+158
	push	ax
	call	near ptr _printf
	pop	cx
	jmp	short @5@30
@5@254:
   ;	
   ;	    }
   ;	
   ;	    for (;;) {
   ;	        printf("input month (1-12): ");
   ;	
	mov	ax,offset DGROUP:s@+182
	push	ax
	call	near ptr _printf
	pop	cx
   ;	
   ;	        if (scanf("%d", &m) != 1)
   ;	
	lea	ax,word ptr [bp-4]
	push	ax
	mov	ax,offset DGROUP:s@+203
	push	ax
	call	near ptr _scanf
	pop	cx
	pop	cx
	cmp	ax,1
	je	short @5@310
	jmp	short @5@58
@5@310:
   ;	
   ;	            return 1;
   ;	        if (m >= 1 && m <= 12)
   ;	
	cmp	word ptr [bp-4],1
	jl	short @5@394
	cmp	word ptr [bp-4],12
	jg	short @5@394
   ;	
   ;	            break;
   ;	
	jmp	short @5@450
@5@394:
   ;	
   ;	        printf("month must be 1-12\n");
   ;	
	mov	ax,offset DGROUP:s@+206
	push	ax
	call	near ptr _printf
	pop	cx
	jmp	short @5@254
@5@450:
   ;	
   ;	    }
   ;	
   ;	    print_cal(y, m);
   ;	
	push	word ptr [bp-4]
	push	word ptr [bp-2]
	call	near ptr _print_cal
	pop	cx
	pop	cx
   ;	
   ;	    return 0;
   ;	
	xor	ax,ax
	jmp	short @5@86
@5@478:
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_main	endp
	?debug	C E9
_TEXT	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	'January'
	db	0
	db	'February'
	db	0
	db	'March'
	db	0
	db	'April'
	db	0
	db	'May'
	db	0
	db	'June'
	db	0
	db	'July'
	db	0
	db	'August'
	db	0
	db	'September'
	db	0
	db	'October'
	db	0
	db	'November'
	db	0
	db	'December'
	db	0
	db	'%d'
	db	10
	db	0
	db	'%s'
	db	10
	db	0
	db	'Su Mo Tu We Th Fr Sa'
	db	10
	db	0
	db	'   '
	db	0
	db	'%2d'
	db	0
	db	10
	db	0
	db	' '
	db	0
	db	10
	db	0
	db	'input year (1900-2099): '
	db	0
	db	'%d'
	db	0
	db	'year must be 1900-2099'
	db	10
	db	0
	db	'input month (1-12): '
	db	0
	db	'%d'
	db	0
	db	'month must be 1-12'
	db	10
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	public	_main
	public	_print_cal
	public	_first_weekday
	public	_days_in_month
	public	_is_leap
_mnames	equ	mnames
_mdays	equ	mdays
	extrn	_scanf:near
	extrn	_printf:near
_s@	equ	s@
	end
