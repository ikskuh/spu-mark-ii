;
; void itoa(char * buffer, int number, int radix)
;
#define ITOA_BUF 2
#define ITOA_NUM 3

itoa:   ; ret → 0
	bpget ; bp  → 1
	spget
	bpset
	
	get -1 ; arg buffer → 2
	get -2 ; arg number → 3
	
	get -3 ; push radix
	st [i1:peek] itoa_radix ; and modify code :)
	st itoa_radix2
	
	; if (number < 0) then
	get ITOA_NUM [f:yes]
	[ex:zero]   jmp itoa_iszero
	[ex:gequal] jmp itoa_nonneg
	; number = -number
	neg
	[i1:peek] set ITOA_NUM
	; (*buffer++) = '-'
	get ITOA_BUF
	[i0:peek] [i1:arg] st8 '-'
	add 1
	set ITOA_BUF
itoa_nonneg:
	; endif
	
	; do
	; get 2
itoa_loop:
	
	; c = itoa_symbols[number % radix]
	mod [i0:peek] [i1:arg]
itoa_radix:
.dw 10

	add itoa_symbols
	ld8
	get ITOA_BUF
	st8
	
	; buffer++
	get ITOA_BUF
	add 1
	set ITOA_BUF
	
	div [i1:arg] [f:yes]
itoa_radix2:
.dw 10
	; while (number > 0)
	
	[ex:greater] jmp itoa_loop
itoa_done_loop:
	pop
	
	get ITOA_BUF
	[i0:pop] [i1:arg] st8 0x00
	
	; Reverse string buffer here

	bpget
	spset
	bpset
	ret

itoa_iszero:
	get ITOA_BUF
	[i0:peek] [i1:arg] st8 '0'
	add 1
	[i0:pop] [i1:arg] st8 0x00
	
	bpget
	spset
	bpset
	ret

itoa_symbols:
.ascii "0123456789ABCDEF"
.align 2