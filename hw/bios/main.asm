.org 0x0000

_start:
	spset stack
	push 1
	push 2
	mul
	st 0x4000

loop1:
	jmp loop2

	nop
	nop
	nop

loop2:
	jmp loop1

hello_text:
	.asciiz "Hello, World!"

# allocate 16 byte of stack in RAM area
.org 0x8000
.align 2
.dw 0, 0, 0, 0
.dw 0, 0, 0, 0
.dw 0, 0, 0, 0
.dw 0, 0, 0, 0
stack:
