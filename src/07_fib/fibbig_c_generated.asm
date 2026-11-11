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
	?debug	S "cbig.c"
	?debug	C E9277C6B5D06636269672E63
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
   ;	static void fib(int n)
   ;	
	assume	cs:_TEXT
fib	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
	push	di
   ;	
   ;	{
   ;	    int i;
   ;	    unsigned t;
   ;	    unsigned carry = 0;
   ;	
	mov	word ptr [bp-2],0
   ;	
   ;	
   ;	    if (done[n])
   ;	
	mov	bx,word ptr [bp+4]
	cmp	byte ptr DGROUP:done[bx],0
	je	short @1@86
   ;	
   ;	        return;                        /* 记忆化: 算过就直接返回 */
   ;	
	jmp	@1@282
@1@86:
   ;	
   ;	    if (n < 2) {                       /* F(0)=0, F(1)=1      */
   ;	
	cmp	word ptr [bp+4],2
	jge	short @1@142
   ;	
   ;	        memo[n][0] = (unsigned char)n;
   ;	
	mov	ax,word ptr [bp+4]
	mov	dx,24
	imul	dx
	mov	dl,byte ptr [bp+4]
	mov	bx,ax
	mov	byte ptr DGROUP:memo[bx],dl
	jmp	short @1@254
@1@142:
   ;	
   ;	        done[n] = 1;
   ;	        return;
   ;	    }
   ;	
   ;	    fib(n - 1);                        /* 递归                 */
   ;	
	mov	ax,word ptr [bp+4]
	dec	ax
	push	ax
	call	near ptr fib
	pop	cx
   ;	
   ;	    fib(n - 2);
   ;	
	mov	ax,word ptr [bp+4]
	add	ax,65534
	push	ax
	call	near ptr fib
	pop	cx
   ;	
   ;	
   ;	    for (i = 0; i < DIG; i++) {        /* 逐位相加, 满 10 进 1 */
   ;	
	xor	si,si
	jmp	short @1@226
@1@170:
   ;	
   ;	        t = (unsigned)memo[n - 1][i] + memo[n - 2][i] + carry;
   ;	
	mov	ax,word ptr [bp+4]
	mov	dx,24
	imul	dx
	mov	bx,ax
	mov	al,byte ptr DGROUP:memo[bx+si-24]
	mov	ah,0
	push	ax
	mov	ax,word ptr [bp+4]
	mov	dx,24
	imul	dx
	mov	bx,ax
	mov	al,byte ptr DGROUP:memo[bx+si-48]
	mov	ah,0
	pop	dx
	add	dx,ax
	add	dx,word ptr [bp-2]
	mov	di,dx
   ;	
   ;	        memo[n][i] = (unsigned char)(t % 10);
   ;	
	mov	ax,di
	mov	bx,10
	xor	dx,dx
	div	bx
	mov	ax,word ptr [bp+4]
	mov	bx,24
	push	dx
	imul	bx
	mov	bx,ax
	pop	ax
	mov	byte ptr DGROUP:memo[bx+si],al
   ;	
   ;	        carry = t / 10;
   ;	
	mov	ax,di
	mov	bx,10
	xor	dx,dx
	div	bx
	mov	word ptr [bp-2],ax
	inc	si
@1@226:
	cmp	si,24
	jl	short @1@170
@1@254:
   ;	
   ;	    }
   ;	    done[n] = 1;
   ;	
	mov	bx,word ptr [bp+4]
	mov	byte ptr DGROUP:done[bx],1
@1@282:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
fib	endp
   ;	
   ;	int main(void)
   ;	
	assume	cs:_TEXT
_main	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
   ;	
   ;	{
   ;	    int n, i;
   ;	
   ;	    printf("n (1-100): ");
   ;	
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _printf
	pop	cx
   ;	
   ;	    if (scanf("%d", &n) != 1)
   ;	
	lea	ax,word ptr [bp-2]
	push	ax
	mov	ax,offset DGROUP:s@+12
	push	ax
	call	near ptr _scanf
	pop	cx
	pop	cx
	cmp	ax,1
	je	short @2@114
@2@58:
   ;	
   ;	        return 1;
   ;	
	mov	ax,1
@2@86:
	jmp	@2@590
@2@114:
   ;	
   ;	    if (n < 1 || n > MAXN) {
   ;	
	cmp	word ptr [bp-2],1
	jl	short @2@170
	cmp	word ptr [bp-2],100
	jle	short @2@198
@2@170:
   ;	
   ;	        printf("n must be 1..100\n");
   ;	
	mov	ax,offset DGROUP:s@+15
	push	ax
	call	near ptr _printf
	pop	cx
	jmp	short @2@58
@2@198:
   ;	
   ;	        return 1;
   ;	    }
   ;	
   ;	    fib(n);
   ;	
	push	word ptr [bp-2]
	call	near ptr fib
	pop	cx
   ;	
   ;	
   ;	    i = DIG - 1;                        /* 跳过前导零           */
   ;	
	mov	si,23
	jmp	short @2@254
@2@226:
   ;	
   ;	    while (i > 0 && memo[n][i] == 0)
   ;	        i--;
   ;	
	dec	si
@2@254:
	or	si,si
	jle	short @2@310
	mov	ax,word ptr [bp-2]
	mov	dx,24
	imul	dx
	mov	bx,ax
	cmp	byte ptr DGROUP:memo[bx+si],0
	je	short @2@226
@2@310:
	jmp	short @2@450
@2@338:
   ;	
   ;	    for (; i >= 0; i--)
   ;	        putchar('0' + memo[n][i]);
   ;	
	inc	word ptr DGROUP:__streams+16
	jge	short @2@394
	mov	ax,word ptr [bp-2]
	mov	dx,24
	imul	dx
	mov	bx,ax
	mov	al,byte ptr DGROUP:memo[bx+si]
	add	al,48
	mov	bx,word ptr DGROUP:__streams+26
	inc	word ptr DGROUP:__streams+26
	mov	byte ptr [bx],al
	mov	ah,0
	jmp	short @2@422
@2@394:
	mov	ax,offset DGROUP:__streams+16
	push	ax
	mov	ax,word ptr [bp-2]
	mov	dx,24
	imul	dx
	mov	bx,ax
	mov	al,byte ptr DGROUP:memo[bx+si]
	add	al,48
	push	ax
	call	near ptr __fputc
	pop	cx
	pop	cx
@2@422:
	dec	si
@2@450:
	or	si,si
	jge	short @2@338
   ;	
   ;	    putchar('\n');
   ;	
	inc	word ptr DGROUP:__streams+16
	jge	short @2@534
	mov	bx,word ptr DGROUP:__streams+26
	inc	word ptr DGROUP:__streams+26
	mov	al,10
	mov	byte ptr [bx],al
	mov	ah,0
	jmp	short @2@562
@2@534:
	mov	ax,offset DGROUP:__streams+16
	push	ax
	mov	al,10
	push	ax
	call	near ptr __fputc
	pop	cx
	pop	cx
@2@562:
   ;	
   ;	    return 0;
   ;	
	xor	ax,ax
	jmp	@2@86
@2@590:
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_main	endp
_TEXT	ends
_BSS	segment word public 'BSS'
done	label	byte
	db	101 dup (?)
memo	label	byte
	db	2424 dup (?)
	?debug	C E9
_BSS	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	'n (1-100): '
	db	0
	db	'%d'
	db	0
	db	'n must be 1..100'
	db	10
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	public	_main
_fib	equ	fib
_done	equ	done
_memo	equ	memo
	extrn	__fputc:near
	extrn	_scanf:near
	extrn	_printf:near
	extrn	__streams:word
_s@	equ	s@
	end

