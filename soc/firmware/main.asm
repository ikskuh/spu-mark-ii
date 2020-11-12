.org 0x0000
	jmp bios_entrypoint

bios_entrypoint:
	st 0xF002, 0x7F01 ; map MMU to second page 0x1000

	; Map some RAM in the upper half
	st 0xF010, 0x8001
	st 0xF012, 0x8011
	st 0xF014, 0x8021
	st 0xF016, 0x8031
	st 0xF018, 0x8041
	st 0xF01A, 0x8051
	st 0xF01C, 0x8061
	st 0xF01E, 0x8071 ; this will unmap the MMU from 0xF000

	st 0x1004, 0x7FD1 ; map vga ctrl to 0x2000
	
	st 0x2000, 0x0000 ; map framebuffer to 0x800000
	st 0x2002, 0x0080

	st 0x100E, 0x8081 ; map RAM to 0x7000…0x7FFF for stack

	; init a stack
	spset 0x8000
	bpset 0x8000
	
	push 0x80
vga_loop:
	push 0x0000 ; push pixel offset
vga_fill:
	
	get 0-1
	get 0-2
	add 0x8000 ; duplicate fb address to stack
	st8 ; store white to current pixel

	add 1 [f:yes] ; increment address by one
	[ex:gequal] jmp vga_fill ; if it overflowed into 0x8000, stop looping
	pop ; remove address
	add 1
	jmp vga_loop

.org 0x0500
fin:
	nop
	nop
	jmp fin
