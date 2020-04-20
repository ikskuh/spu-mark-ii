.org 0x0000
	spset 0x6020    ; 16 Element Stack
	
	push startup_msg
	push _after
	jmp puts
_after:
	pop
	
	push 1000

	st8 0x8000, 0x00
loop:
	ld8 0x8000 [f:yes]
	[ex:nonzero] st8 0x4000 [i1:peek]
	[ex:nonzero] st8 0x8000, 0x00
	pop
	ld 0x4000 [f:yes]
	[ex:gequal] st8 0x4000 [i1:peek]
	pop

	push 0xFFFF
delay:
	sub 1 [f:yes]
	[ex:nonzero] jmp delay
	pop

	st8 0x4000, '!'

	sub 1 [f:yes]
	[ex:nonzero] jmp loop
	pop

.dw 0x2000 ; invalid instruction

startup_msg:
	.asciiz "Hello, World!\r\n"

puts:
	bpget
	spget
	bpset
	
	get 2 ; arg 1
puts_loop:
	ld8 [i0:peek] [f:yes]
	[ex:nonzero] st8 0x4000
	[ex:nonzero] add 1
	[ex:nonzero] jmp puts_loop
	pop

	bpget
	spset
	bpset
	ret