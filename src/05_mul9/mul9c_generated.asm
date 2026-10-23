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
	?debug	S "mul9c.c"
	?debug	C E97395575D076D756C39632E63
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
   ;	    int i, j;
   ;	
   ;	    printf("The 9mul9 table:\n");
   ;	
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _printf
	pop	cx
   ;	
   ;	    for (i = 9; i >= 1; i--) {
   ;	
	mov	si,9
	jmp	short @1@366
@1@58:
   ;	
   ;	        for (j = 1; j <= i; j++) {
   ;	
	mov	di,1
	jmp	short @1@226
@1@86:
   ;	
   ;	            printf("%d*%d=%d", i, j, i * j);
   ;	
	mov	ax,si
	imul	di
	push	ax
	push	di
	push	si
	mov	ax,offset DGROUP:s@+18
	push	ax
	call	near ptr _printf
	add	sp,8
   ;	
   ;	            if (j < i) {
   ;	
	cmp	di,si
	jge	short @1@198
   ;	
   ;	                putchar(' ');
   ;	
	inc	word ptr DGROUP:__streams+16
	jge	short @1@170
	mov	bx,word ptr DGROUP:__streams+26
	inc	word ptr DGROUP:__streams+26
	mov	al,32
	mov	byte ptr [bx],al
	mov	ah,0
	jmp	short @1@198
@1@170:
	mov	ax,offset DGROUP:__streams+16
	push	ax
	mov	al,32
	push	ax
	call	near ptr __fputc
	pop	cx
	pop	cx
@1@198:
	inc	di
@1@226:
	cmp	di,si
	jle	short @1@86
   ;	
   ;	            }
   ;	        }
   ;	        putchar('\n');
   ;	
	inc	word ptr DGROUP:__streams+16
	jge	short @1@310
	mov	bx,word ptr DGROUP:__streams+26
	inc	word ptr DGROUP:__streams+26
	mov	al,10
	mov	byte ptr [bx],al
	mov	ah,0
	jmp	short @1@338
@1@310:
	mov	ax,offset DGROUP:__streams+16
	push	ax
	mov	al,10
	push	ax
	call	near ptr __fputc
	pop	cx
	pop	cx
@1@338:
	dec	si
@1@366:
	cmp	si,1
	jge	short @1@58
   ;	
   ;	    }
   ;	    return 0;
   ;	
	xor	ax,ax
	jmp	short @1@422
@1@422:
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
	db	'The 9mul9 table:'
	db	10
	db	0
	db	'%d*%d=%d'
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	public	_main
	extrn	__fputc:near
	extrn	_printf:near
	extrn	__streams:word
_s@	equ	s@
	end
