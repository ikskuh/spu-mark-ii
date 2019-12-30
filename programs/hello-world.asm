.org 0x0000

_start:
	push msg
_loop:
	[i0:peek] ld8 [f:yes]
	[ex:nonzero] st8 0x1000
	[ex:nonzero] add 1
	[ex:nonzero] rjmp -3

.org 0x1000
msg:
.asciiz "Hello World\r\n"
.align 2
