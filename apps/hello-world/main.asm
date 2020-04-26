; Example application
; Prints "Hello, World!\r\n" to the serial console
; by using ROM routines, then returns to the BIOS.
.org 0x8000

app_main:
	push app_msg
	ipget 2
	ld 0x0006 [out:jmp]
	pop

app_loop:
	ld 0x4000 [f:yes]
	[ex:less] jmp app_loop [i1:pop]
	pop

  ret

app_msg:
.asciiz "\rHello, World!"
.align 2
