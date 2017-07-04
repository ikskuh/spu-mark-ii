.org 0x0000
	
	jmp main

_interrupts:
	; 1-8
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	
	; 9-16
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	
	; 17-24
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	rjmp -4
	jmp syscall ; intr24 → syscall
_interruptsEnd:
