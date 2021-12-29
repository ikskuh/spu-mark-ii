; Example application
; Prints "Hello, World!\r\n" to the serial console
; by using ROM routines, then returns to the BIOS.

.include "../library/bios.inc"

.equ UART_RXD,0x1000

; Programs start at 0x8000
.org APP_START

	; call puts(app_msg)
	push app_msg
	ld ROM_PUTS
	call
	pop

	; wait until we receive a character from serial
app_loop:
	ld UART_RXD [f:yes]
	[ex:less] jmp app_loop [i1:pop]
	pop

  ret

app_msg:
.asciiz "\rHello, World!"
.align 2
