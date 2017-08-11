
.org 0x0000
init:
	; Map Bank 15(0xF000) to Device 128 (0x800000)
	map 15, 0x8000
	
	st8 0xF000, 'H'
	st8 0xF000, 'e'
	st8 0xF000, 'l'
	st8 0xF000, 'l'
	st8 0xF000, 'o'
	st8 0xF000, '!'
	st8 0xF000, '\n'
	
	; Echo loop :)
loop:
	ld8 0xF000
	st8 0xF000
	jmp loop