.include "../library/ashet/syscalls.inc"
.include "../library/ashet/io-page.inc"

.org 0x0000

; interrupt table at the start of the ROM
; this must be fixed in location
bios.vectors:
.dw bios.entrypoint                 ; Reset
.dw bios.interrupt.handler.nmi      ; NMI
.dw bios.interrupt.handler.bus      ; BUS
.dw 0x0000                          ; RESERVED
.dw bios.interrupt.handler.arith    ; ARITH
.dw bios.interrupt.handler.software ; SOFTWARE
.dw bios.interrupt.handler.reserved ; RESERVED
.dw bios.interrupt.handler.irq      ; IRQ

; the bios syscall table
; this must be fixed in location, each slot in the list is 2 word wide.
bios.syscall.table:
	jmp bios.syscall.uart.setup
	jmp bios.syscall.uart.status
	jmp bios.syscall.uart.writeChar
	jmp bios.syscall.uart.readChar

; we spare half of the first page for potential future syscall entries
; so we don't have to relocate everything

; so the rest of the bios code starts after the first half page
.org 0x0800

bios.syscall.invalid:
  ret

; uart.setup(mode_selector: u16, baud_selector: u16) void
;   changes the UART configuration
;   mode_selector:
;        0…7 => uart [ COM1, COM2, IR1, -, … ]
;        8…9 => parity [ none, even, odd, - ]
;      10…10 => stop bits [ one, two ]
;      11…13 => data width [ 5, 6, 7, 8, 9, -, -, - ]
;   baud_selector:
;     0 =>   1200
;     1 =>   2400
;     2 =>   4800
;     3 =>  19200
;     4 =>  38400
;     5 =>  57600
;     6 => 115200
;
bios.syscall.uart.setup:
	; TODO: Implement this
	ret

; uart.status(uart: u16) u16
;   returns the status of a uart
;   uart:
;     0…7 => uart [ COM1, COM2, IR1, -, … ]
;   <return>:
;     0…0 => ???
;
bios.syscall.uart.status:
  set 2, 0x0000 ; just return empty status for now
	ret

; uart.writeChar(uart: u16, char: u16) void 
;   writes a character to the uart
;   uart:
;     0…7 => uart [ COM1, COM2, IR1, -, … ]
;   char:
;     0…9 => max bits to send over the wire
;
bios.syscall.uart.writeChar:
  get -2
	st 0x4000
	ret

; uart.readChar(uart: u16) u16 
;   writes a character to the uart
;   uart:
;     0…7 => uart [ COM1, COM2, IR1, -, … ]
;   <return>:
;       0…9 => the bits received from the wire
;     15…15 => if 1, the fifo was empty.
;      FR.Z => if 1, the received bits are all 0
;      FR.N => if 1, the fifo was empty.
;
bios.syscall.uart.readChar:
  set 2, 0xFFFF ; just return "empty fifo" for now
	ret

bios.interrupt.handler.nmi:
	st 'N', 0x4000 
	jmp bios.hang

bios.interrupt.handler.bus:
	st 'B', 0x4000 
	jmp bios.hang

bios.interrupt.handler.arith:
	st 'A', 0x4000
	iret

bios.interrupt.handler.software:
	st 'S', 0x4000
	iret

bios.interrupt.handler.reserved:
	st 'R', 0x4000
	iret

bios.interrupt.handler.irq:
	st 'I', 0x4000 
	iret

bios.entrypoint:
TODO: Rebuild this to be correct
	st 0x7FE1, 0xF002 ; map I/O page to second page 0x1000

	; Map some RAM in the upper half
	st 0x8001, 0xF010
	st 0x8011, 0xF012
	st 0x8021, 0xF014
	st 0x8031, 0xF016
	st 0x8041, 0xF018
	st 0x8051, 0xF01A
	st 0x8061, 0xF01C
	st 0x8071, 0xF01E ; this will unmap the MMU from 0xF000

	st 0x0000, 0x1000 ; map framebuffer to 0x800000
	st 0x0080, 0x1002

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
	get -1
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
bios.hang:
	frset 0x0000 ; disable all maskable interrupts
	jmp bios.hang

