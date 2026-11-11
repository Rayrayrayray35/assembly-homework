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
	?debug	S "cfib.c"
	?debug	C E9277C6B5D06636669622E63
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
   ;	unsigned long fib(unsigned n)
   ;	
	assume	cs:_TEXT
_fib	proc	near
	push	bp
	mov	bp,sp
	push	si
	mov	si,word ptr [bp+4]
   ;	
   ;	{
   ;	    if (n < 2)
   ;	
	cmp	si,2
	jae	short @1@86
   ;	
   ;	        return n;
   ;	
	mov	ax,si
	xor	dx,dx
	jmp	short @1@114
@1@86:
   ;	
   ;	    return fib(n - 1) + fib(n - 2);
   ;	
	mov	ax,si
	dec	ax
	push	ax
	call	near ptr _fib
	pop	cx
	push	ax
	push	dx
	mov	ax,si
	sub	ax,2
	push	ax
	call	near ptr _fib
	pop	cx
	mov	bx,dx
	pop	dx
	pop	cx
	add	cx,ax
	adc	dx,bx
	mov	ax,cx
	jmp	short @1@114
@1@114:
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_fib	endp
   ;	
   ;	int main(void)
   ;	
	assume	cs:_TEXT
_main	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
   ;	
   ;	{
   ;	    unsigned n;
   ;	
   ;	    printf("n (1-40): ");
   ;	
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _printf
	pop	cx
   ;	
   ;	    if (scanf("%u", &n) != 1)
   ;	
	lea	ax,word ptr [bp-2]
	push	ax
	mov	ax,offset DGROUP:s@+11
	push	ax
	call	near ptr _scanf
	pop	cx
	pop	cx
	cmp	ax,1
	je	short @2@114
   ;	
   ;	        return 1;
   ;	
	mov	ax,1
@2@86:
	jmp	short @2@142
@2@114:
   ;	
   ;	    printf("F(%u) = %lu\n", n, fib(n));
   ;	
	push	word ptr [bp-2]
	call	near ptr _fib
	pop	cx
	push	dx
	push	ax
	push	word ptr [bp-2]
	mov	ax,offset DGROUP:s@+14
	push	ax
	call	near ptr _printf
	add	sp,8
   ;	
   ;	    return 0;
   ;	
	xor	ax,ax
	jmp	short @2@86
@2@142:
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
	db	'n (1-40): '
	db	0
	db	'%u'
	db	0
	db	'F(%u) = %lu'
	db	10
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	public	_main
	public	_fib
	extrn	_scanf:near
	extrn	_printf:near
_s@	equ	s@
	end

