syscall:
	
	push syscall_msg
	CALL(puts)
	pop ; remove arg
	
	ret

syscall_msg:
.asciiz "[Syscall]"
.align 2