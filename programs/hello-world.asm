.org 0x0000
.equ one 1

_start:
	push msg
_loop: ; 0x04
	[i0:peek] ld8i [f:yes]
	[ex:nonzero] out 0x00
	[ex:nonzero] add one
	[ex:nonzero] jmp _loop
	rjmp -4

.org 0x1000
msg:
.asciiz "Hello World\r\n"
.align 2