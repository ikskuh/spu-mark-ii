main:

	; push main_msg
	; CALL(puts)
	; pop
	
	out 0x00, 'S'
	
	setint 1
	int 24
	
	out 0x00, 'E'
	
	rjmp -4

main_msg:
.asciiz "Hello, DOS!\r\n"
.align 2