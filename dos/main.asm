main:
	
	push 16
	push 1337
	push main_buf
	CALL(itoa)
	pop
	pop
	pop

 	push main_msg
 	CALL(puts)
 	pop
	
	push main_buf
	CALL(puts)
	pop
	out 0x00, '\n'
	
	
	setint 1
	int 24, 0xFF
	
	out 0x00, 'E'
	
	rjmp -8

main_msg:
.asciiz "Hello, DOS!\r\n"

main_buf:
.asciiz "????????????????"
.align 2