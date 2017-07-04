syscall:
	
	push syscall_msg
	push syscall_ret
	jmp puts
syscall_ret:
	pop ; remove arg
	
	rjmp -4
	ret

syscall_msg:
.asciiz "Syscall was invoked!"
.align 2