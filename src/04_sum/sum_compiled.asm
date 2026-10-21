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
	?debug	S "sum.c"
	?debug	C E96E98505D0573756D2E63
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
_TEXT	segment byte public 'CODE'
   ;	
   ;	int main(void)
   ;	
	assume	cs:_TEXT
_main	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	{
   ;	    int i;
   ;	    int sum = 0;                 /* 累加和, 用 16 位 int(结果 5050 超过 255) */
   ;	
	xor	di,di
   ;	
   ;	
   ;	    for (i = 1; i <= 100; i++)   /* i = 1,2,...,100 */
   ;	
	mov	si,1
	jmp	short @1@114
@1@58:
   ;	
   ;	        sum += i;                /* sum = sum + i */
   ;	
	add	di,si
	inc	si
@1@114:
	cmp	si,100
	jle	short @1@58
   ;	
   ;	
   ;	    printf("%d\n", sum);         /* 输出 5050 */
   ;	
	push	di
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _printf
	pop	cx
	pop	cx
   ;	
   ;	    return 0;
   ;	
	xor	ax,ax
	jmp	short @1@170
@1@170:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_main	endp
	?debug	C E9
_TEXT	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	'%d'
	db	10
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	public	_main
	extrn	_printf:near
_s@	equ	s@
	end
