
.org 0x0000

_start:
	push 0x1000 ; msg
_loop: ; 0x04
	[i0:peek] ld8i [f:yes]
	[ex:nonzero] out 0x00
	[ex:nonzero] add 1
	[ex:nonzero] jmp 0x04 ; _loop
	jmp 0x0012
	
.org 0x1000
msg:
.db 'H', 'e', 'l', 'l', 'o', ' '
.db 'W', 'o', 'r', 'l', 'd', '!', '\r', '\n'
.db 0
.align 2
