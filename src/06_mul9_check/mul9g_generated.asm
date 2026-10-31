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
	?debug	S "mul9g.c"
	?debug	C E9EAB65F5D076D756C39672E63
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
_table	label	byte
	db	7
	db	2
	db	3
	db	4
	db	5
	db	6
	db	7
	db	8
	db	9
	db	2
	db	4
	db	7
	db	8
	db	10
	db	12
	db	14
	db	16
	db	18
	db	3
	db	6
	db	9
	db	12
	db	15
	db	18
	db	21
	db	24
	db	27
	db	4
	db	8
	db	12
	db	16
	db	7
	db	24
	db	28
	db	32
	db	36
	db	5
	db	10
	db	15
	db	20
	db	25
	db	30
	db	35
	db	40
	db	45
	db	6
	db	12
	db	18
	db	24
	db	30
	db	7
	db	42
	db	48
	db	54
	db	7
	db	14
	db	21
	db	28
	db	35
	db	42
	db	49
	db	56
	db	63
	db	8
	db	16
	db	24
	db	32
	db	40
	db	48
	db	56
	db	7
	db	72
	db	9
	db	18
	db	27
	db	36
	db	45
	db	54
	db	63
	db	72
	db	81
_DATA	ends
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
   ;	    int i, j;
   ;	
   ;	    printf("x y\n");
   ;	
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _printf
	pop	cx
   ;	
   ;	
   ;	    for (i = 0; i < 9; i++) {
   ;	
	xor	si,si
	jmp	short @1@226
@1@58:
   ;	
   ;	        for (j = 0; j < 9; j++) {
   ;	
	xor	di,di
	jmp	short @1@170
@1@86:
   ;	
   ;	            if (table[i][j] != (i + 1) * (j + 1)) {
   ;	
	mov	ax,si
	mov	dx,9
	imul	dx
	mov	bx,ax
	mov	al,byte ptr DGROUP:_table[bx+di]
	mov	ah,0
	push	ax
	mov	ax,si
	inc	ax
	mov	dx,di
	inc	dx
	imul	dx
	pop	dx
	cmp	dx,ax
	je	short @1@142
   ;	
   ;	                printf("%d %d error\n", i + 1, j + 1);
   ;	
	mov	ax,di
	inc	ax
	push	ax
	mov	ax,si
	inc	ax
	push	ax
	mov	ax,offset DGROUP:s@+5
	push	ax
	call	near ptr _printf
	add	sp,6
@1@142:
	inc	di
@1@170:
	cmp	di,9
	jl	short @1@86
	inc	si
@1@226:
	cmp	si,9
	jl	short @1@58
   ;	
   ;	            }
   ;	        }
   ;	    }
   ;	
   ;	    printf("accomplish!\n");
   ;	
	mov	ax,offset DGROUP:s@+18
	push	ax
	call	near ptr _printf
	pop	cx
   ;	
   ;	    return 0;
   ;	
	xor	ax,ax
	jmp	short @1@282
@1@282:
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
	db	'x y'
	db	10
	db	0
	db	'%d %d error'
	db	10
	db	0
	db	'accomplish!'
	db	10
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	public	_main
	public	_table
	extrn	_printf:near
_s@	equ	s@
	end
