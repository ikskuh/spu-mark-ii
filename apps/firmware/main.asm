.org 0x0000
bios_vectors:
.dw bios_entrypoint ; Reset
.dw handle_nmi      ; NMI
.dw handle_bus      ; BUS
.dw 0x0000          ; RESERVED
.dw handle_arith    ; ARITH
.dw handle_software ; SOFTWARE
.dw handle_reserved ; RESERVED
.dw handle_irq      ; IRQ

handle_nmi:
	st 'N', 0x4000 
	jmp hang_loop

handle_bus:
	st 'B', 0x4000 
	jmp hang_loop

handle_arith:
	st 'A', 0x4000
	iret

handle_software:
	st 'S', 0x4000
	iret

handle_reserved:
	st 'R', 0x4000
	iret

handle_irq:
	st 'I', 0x4000 
	iret

hang_loop:
	frset 0x0000 ; disable all IRQs
	jmp hang_loop

bios_entrypoint:
	st 0x7F01, 0xF002 ; map MMU to second page 0x1000

	; Map some RAM in the upper half
	st 0x8001, 0xF010
	st 0x8011, 0xF012
	st 0x8021, 0xF014
	st 0x8031, 0xF016
	st 0x8041, 0xF018
	st 0x8051, 0xF01A
	st 0x8061, 0xF01C
	st 0x8071, 0xF01E ; this will unmap the MMU from 0xF000

	st 0x7FD1, 0x1004 ; map vga ctrl to 0x2000
	
	st 0x0000, 0x2000 ; map framebuffer to 0x800000
	st 0x0080, 0x2002

	st 0x8101, 0x100E ; map RAM to 0x7000…0x7FFF for stack

	st 0x7F21, 0x1008 ; map UART0 to 0x4000

	; init a stack
	spset 0x8000
	bpset 0x8000

	frset 0xFFF0, ~0x00F0

	st 'H',  0x4000
	st 'e',  0x4000
	st 'l',  0x4000
	st 'l',  0x4000
	st 'o',  0x4000
	st '\r', 0x4000
	st '\n', 0x4000

	push 0x80
vga_loop:
	push 0x8000 ; push pixel offset
vga_fill:
	
	dup ; duplicate address
	bswap [i0:peek]
	xor
	get 0-1
	add

;.dw 0x8001 ; enable tracing
	st8 [i1:peek]; store color to current pixel
;.dw 0x8000 ; disable tracing

	add 1 [f:yes] ; increment address by one
	[ex:nonzero] jmp vga_fill ; if it overflowed into 0x0000, stop looping
	pop ; remove address
	add 1
	jmp vga_loop

.org 0x0500
fin:
	nop
	nop
	jmp fin
