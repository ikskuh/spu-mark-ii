

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
	spset 0x6100    ; 128 Element Stack

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
	.ascii     "  rb - read byte\r\n"
	.ascii     "  rw - read word\r\n"
	.ascii     "  wb - write byte\r\n"
	.ascii     "  ww - write word\r\n"
	.ascii     "  g  - run code from 0x8000\r\n"
	.db 0
.align 2

bios_start_app:
	ipget 2
	jmp serial_clear_screen

	; clear stack to inital value
	spset 0x6100
	push bios_entrypoint ; when app returns, restart OS
	jmp 0x8000           ; jump to app entry point

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