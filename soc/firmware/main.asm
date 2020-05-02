

.include "../../apps/library/ascii.inc"

.org 0x0000
	jmp bios_entrypoint

; this table contains a list of ROM available
; functions for the Ashet home computer
; This table must be at 0x0004, entries can
; be called indirect as with the standard calling convention:
;
;   ; push args/retval here
;   ipget 2             ; push return adresse
;   ld 0x0004 [out:jmp] ; indirect jump to /puts/
;   ; pop args/retval here
;
bios_jumptable:
	.dw serial_clear_screen
	.dw serial_puts ; fn puts(str: [*:0]const u8) void
	.dw serial_read_line

; =============================================================================
; Core OS / Monitor Features
; =============================================================================

; fn bios_entrypoint() noreturn
; this restarts the computer
bios_entrypoint:
	spset 0x7000    ; 128 Element Stack

	push bios_startup_msg
	ipget 2
	jmp serial_puts
	pop

; go into the bios mainmenu
	jmp bios_mainmenu

bios_startup_msg:
	.db    ASCII_ESC, '[', 'H' ; Home Cursor
	.db    ASCII_ESC, '[', 'J' ; Erase Display
	.ascii ".==========================.\r\n"
	.ascii "| ASHET HOME COMPUTER BIOS |\r\n"
	.ascii "'=========================='\r\n"
	.ascii "\r\n"
	.db 0
.align 2

; fn bios_mainmenu() noreturn
; the main menu of the Ashet BIOS
; 
bios_mainmenu:
	st 0x4000, ASCII_CR
	st 0x4000, '>'
	st 0x4000, ' '
	st 0x4000, ' '
	st 0x4000, ASCII_BS

bios_mainmenu_waitkey:
	ld 0x4000 [f:yes]
	[ex:less] jmp bios_mainmenu_waitkey [i1:pop] ; consume negative value and loop

	st 0x4000 [i1:peek]

	cmpp 'h' 
	[ex:zero] jmp bios_helpmenu [i1:pop] ; jmp and discard

	cmpp 'g' 
	[ex:zero] jmp bios_start_app [i1:pop] ; jmp and discard

	cmpp 'x' 
	[ex:zero] jmp bios_readline_demo [i1:pop] ; jmp and discard

	cmpp 'l'
	[ex:zero] jmp bios_load_ihex [i1:pop] ; jmp and discard

	pop ; eat the input

	; we don't know the command, so just clear the input
	; and restart
	jmp bios_mainmenu


bios_helpmenu:
	push bios_helpmenu_msg
	ipget 2
	jmp serial_puts
	pop

	jmp bios_mainmenu

bios_helpmenu_msg:
	.ascii "\r\navailable commands:\r\n"
	.ascii     "  h  - display help\r\n"
	;.ascii     "  rb - read byte\r\n"
	;.ascii     "  rw - read word\r\n"
	;.ascii     "  wb - write byte\r\n"
	;.ascii     "  ww - write word\r\n"
	.ascii     "  g  - run code from 0x8000\r\n"
	.ascii     "  l  - loads an ihex file\r\n"
	.ascii     "  x  - tests serial_read_line\r\n"
	.db 0
.align 2

bios_start_app:
	ipget 2
	jmp serial_clear_screen

	; clear stack to inital value
	spset 0x7000
	push bios_entrypoint ; when app returns, restart OS
	jmp 0x8000           ; jump to app entry point

; Reads an ihex file from stdin, then returns to main menu
bios_load_ihex:
	push bios_load_ihex_msg
	ipget 2
	jmp serial_puts
	pop

.wait_for_record:
	ld 0x4000
	cmp ':'
	[ex:less] jmp .wait_for_record 

	push 0
	ipget 2
	jmp bios_rcv_hexbyte

	jmp bios_mainmenu

bios_load_ihex_msg:
	.asciiz "\r\nawaiting ihex file...\r\n"

; reads two hex chars from the serial port, returns them as a byte
; ignores all non-hex bytes
bios_rcv_hexbyte:
	bpget
	spget
	bpset

.waitchr_high:
	ld 0x4000
	sgnext [f:yes]
	[ex:less] jmp .waitchr_high [i1:pop] ; if >= 0x80
	add bios_rcv_hexbyte_lut
	ld8
	sgnext [f:yes]
	[ex:less] jmp .waitchr_high [i1:pop] ; if lut[c] >= 0x80

	; make it upper word
	lsl
	lsl
	lsl
	lsl

.waitchr_low:
	ld 0x4000
	sgnext [f:yes]
	[ex:less] jmp .waitchr_low [i1:pop] ; if >= 0x80
	add bios_rcv_hexbyte_lut
	ld8
	sgnext [f:yes]
	[ex:less] jmp .waitchr_low [i1:pop] ; if lut[c] >= 0x80

	or ; combine upper and lower nibble

	set 2 ; store result

	bpget
	spset
	bpset
	ret

bios_rcv_hexbyte_lut:
.db 0xFF ; 0x0
.db 0xFF ; 0x1
.db 0xFF ; 0x2
.db 0xFF ; 0x3
.db 0xFF ; 0x4
.db 0xFF ; 0x5
.db 0xFF ; 0x6
.db 0xFF ; 0x7
.db 0xFF ; 0x8
.db 0xFF ; 0x9
.db 0xFF ; 0xa
.db 0xFF ; 0xb
.db 0xFF ; 0xc
.db 0xFF ; 0xd
.db 0xFF ; 0xe
.db 0xFF ; 0xf
.db 0xFF ; 0x10
.db 0xFF ; 0x11
.db 0xFF ; 0x12
.db 0xFF ; 0x13
.db 0xFF ; 0x14
.db 0xFF ; 0x15
.db 0xFF ; 0x16
.db 0xFF ; 0x17
.db 0xFF ; 0x18
.db 0xFF ; 0x19
.db 0xFF ; 0x1a
.db 0xFF ; 0x1b
.db 0xFF ; 0x1c
.db 0xFF ; 0x1d
.db 0xFF ; 0x1e
.db 0xFF ; 0x1f
.db 0xFF ; 0x20
.db 0xFF ; 0x21
.db 0xFF ; 0x22
.db 0xFF ; 0x23
.db 0xFF ; 0x24
.db 0xFF ; 0x25
.db 0xFF ; 0x26
.db 0xFF ; 0x27
.db 0xFF ; 0x28
.db 0xFF ; 0x29
.db 0xFF ; 0x2a
.db 0xFF ; 0x2b
.db 0xFF ; 0x2c
.db 0xFF ; 0x2d
.db 0xFF ; 0x2e
.db 0xFF ; 0x2f
.db 0x00 ; 0x30
.db 0x01 ; 0x31
.db 0x02 ; 0x32
.db 0x03 ; 0x33
.db 0x04 ; 0x34
.db 0x05 ; 0x35
.db 0x06 ; 0x36
.db 0x07 ; 0x37
.db 0x08 ; 0x38
.db 0x09 ; 0x39
.db 0xFF ; 0x3a
.db 0xFF ; 0x3b
.db 0xFF ; 0x3c
.db 0xFF ; 0x3d
.db 0xFF ; 0x3e
.db 0xFF ; 0x3f
.db 0xFF ; 0x40
.db 0x0A ; 0x41
.db 0x0B ; 0x42
.db 0x0C ; 0x43
.db 0x0D ; 0x44
.db 0x0E ; 0x45
.db 0x0F ; 0x46
.db 0xFF ; 0x47
.db 0xFF ; 0x48
.db 0xFF ; 0x49
.db 0xFF ; 0x4a
.db 0xFF ; 0x4b
.db 0xFF ; 0x4c
.db 0xFF ; 0x4d
.db 0xFF ; 0x4e
.db 0xFF ; 0x4f
.db 0xFF ; 0x50
.db 0xFF ; 0x51
.db 0xFF ; 0x52
.db 0xFF ; 0x53
.db 0xFF ; 0x54
.db 0xFF ; 0x55
.db 0xFF ; 0x56
.db 0xFF ; 0x57
.db 0xFF ; 0x58
.db 0xFF ; 0x59
.db 0xFF ; 0x5a
.db 0xFF ; 0x5b
.db 0xFF ; 0x5c
.db 0xFF ; 0x5d
.db 0xFF ; 0x5e
.db 0xFF ; 0x5f
.db 0xFF ; 0x60
.db 0x0a ; 0x61
.db 0x0b ; 0x62
.db 0x0c ; 0x63
.db 0x0d ; 0x64
.db 0x0e ; 0x65
.db 0x0f ; 0x66
.db 0xFF ; 0x67
.db 0xFF ; 0x68
.db 0xFF ; 0x69
.db 0xFF ; 0x6a
.db 0xFF ; 0x6b
.db 0xFF ; 0x6c
.db 0xFF ; 0x6d
.db 0xFF ; 0x6e
.db 0xFF ; 0x6f
.db 0xFF ; 0x70
.db 0xFF ; 0x71
.db 0xFF ; 0x72
.db 0xFF ; 0x73
.db 0xFF ; 0x74
.db 0xFF ; 0x75
.db 0xFF ; 0x76
.db 0xFF ; 0x77
.db 0xFF ; 0x78
.db 0xFF ; 0x79
.db 0xFF ; 0x7a
.db 0xFF ; 0x7b
.db 0xFF ; 0x7c
.db 0xFF ; 0x7d
.db 0xFF ; 0x7e
.db 0xFF ; 0x7f

; =============================================================================
; BIOS Functionality
; =============================================================================

; fn(str: [*:0]const u8) void
; prints a string to the serial terminal
serial_puts:
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


; fn() void
; clears the serial terminal
serial_clear_screen:
 ; Home Cursor
	st 0x4000, ASCII_ESC
	st 0x4000, '['
	st 0x4000, 'H'
	
	; Erase Display
	st 0x4000, ASCII_ESC
	st 0x4000, '['
	st 0x4000, 'J' 

	ret

bios_readline_demo:

	st 0x4000, ASCII_CR
	st 0x4000, ASCII_LF

	st 0x4000, '$'
	st 0x4000, ' '

	push 32
	push bios_readline_demo_buf
	ipget 2
	jmp serial_read_line
	pop
	pop

	st 0x4000, ASCII_CR
	st 0x4000, ASCII_LF

	st 0x4000, '>'
	push bios_readline_demo_buf
	ipget 2
	jmp serial_puts
	pop
	st 0x4000, '<'

	st 0x4000, ASCII_CR
	st 0x4000, ASCII_LF

	jmp bios_mainmenu


; fn(str: *u8, len: u16) void
; reads a line from the serial terminal. Allows the user to edit the text
; with backspace and correct the input by that.
; Maximum string length is determined by `len` and the string is guaranteed
; to be zero-terminated in the end.
; User can both enter text and confirm with `Return` or cancel input by
; pressing `Escape`, then an empty string will be returned.
serial_read_line:
	bpget
	spget
	bpset

	; len=3
	; str=2
	; ret=1
	; bpc=0
	; off=-1

	push 0 ; offset = -1
.input_loop:
	ld 0x4000 [f:yes]
	[ex:less] jmp .input_loop [i1:pop]

	cmpp ASCII_ESC
	[ex:zero] jmp .clr_input_and_return

	cmpp ASCII_CR
	[ex:zero] jmp .return ; accept input

	cmpp ASCII_RUB
	[ex:zero] jmp .delchr [i1:pop]

	cmpp 0x20                 ; when "control"
	[ex:less] jmp .input_loop ; don't accept character as input and store it

	; .dw 0x8001 ; enable tracing

	; check if our offset exceeds the length
	get 0-1
	get 3
	sub 1 ; subtract byte for NUL terminator
	cmp
	[ex:lequal] jmp .input_loop [i1:pop] ; discard input, text too long

	; echo character to serial port
	st8 0x4000 [i1:peek]

	; calculate target address
	get 2
	get 0-1
	add
	; store into target string
	st8

	add 1 ; increment offset
	get 2
	add [i1:peek] ; calculate next addr
	st8 [i0:pop] [i1:imm] ASCII_NUL ; write NUL terminator

	jmp .input_loop

.delchr:
	cmpp 0
	[ex:zero] jmp .input_loop ; don't delete when string is zero-length

	; subtract one, store NUL terminator to new pos
	sub 1
	get 2
	add [i1:peek]
	st8 [i0:pop] [i1:imm] ASCII_NUL

	; erase character from terminal
	st8 0x4000, ASCII_BS
	st8 0x4000, ' '
	st8 0x4000, ASCII_BS

	jmp .input_loop

.clr_input_and_return:
	get 2
	st8 [i0:pop] [i1:imm] ASCII_NUL
.return:
	bpget
	spset
	bpset
	ret

; end of code
.org 0x6000
bios_readline_demo_buf:
.space 32