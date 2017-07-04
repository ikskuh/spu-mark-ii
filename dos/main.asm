main:
	push main_msg
	push main_return
	jmp puts
main_return:
	pop
	
	rjmp -4

main_msg:
.asciiz "Hello, DOS!\r\n"
.align 2