.org 0x0000
	spset 0x6020    ; 16 Element Stack
	
	push startup_msg
	push _after
	jmp puts
_after:
	pop
	
	st8 0x8000, 0x00
loop:
	ld8 0x8000 [f:yes]
	[ex:nonzero] st8 0x4000 [i1:peek]
	[ex:nonzero] st8 0x8000, 0x00
	pop
	ld8 0x4000 [f:yes]
	[ex:gequal] st8 0x4000 [i1:peek]
	pop
	jmp loop

startup_msg:
	.asciiz "Hello, World!\r\n"

puts:
	bpget
	spget
	bpset
	
	st8 0x4000, 'A'
	st8 0x4000, 'B'
	st8 0x4000, 'C'

	bpget
	spset
	bpget
	ret