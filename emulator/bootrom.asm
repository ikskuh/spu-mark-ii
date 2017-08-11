
.org 0x0000
init:
	; Map Bank 15(0xF000) to Device 128 (0x800000)
	map 15, 0x8000
	map  8, 0x0100
	spset 0x8000

	push msg
printstr:
	[i0:peek] ld8 [f:yes]
	[ex:nonzero] st8 0xF000
	[ex:nonzero] add 1
	[ex:nonzero] jmp printstr
	pop
	
loop:
	ld8 0xF000
	st8 0xF000
	jmp loop
	
msg:
.asciiz "Hello World\r\n"
.align 2
