.org 0x0000
.equ grossesH 'H'

_start:
	ld data
	out 0
	rjmp -4

data:
.dw grossesH
