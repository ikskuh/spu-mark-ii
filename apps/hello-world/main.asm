; Example application
; Prints "Hello, World!\r\n" to the serial console
; by using ROM routines, then returns to the BIOS.

; This is the location of `puts(char * str)` in the ROM.
; We can use this to clarify where we're jumping to
.equ ROM_PUTS, 0x0006

; Programs start at 0x8000
.org 0x8000

	; call puts(app_msg)
	push app_msg
	ipget 2
	ld ROM_PUTS [out:jmp]
	pop

	; wait until we receive a character from serial
app_loop:
	ld 0x4000 [f:yes]
	[ex:less] jmp app_loop [i1:pop]
	pop

  ret

app_msg:
.asciiz "\rHello, World!"
.align 2
