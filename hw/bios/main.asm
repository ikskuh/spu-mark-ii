.org 0x0000
	spset 0x6020    ; 16 Element Stack
	st 0x4000, 'H'  ; Startup Message
	st 0x4000, 'e'
	st 0x4000, 'l'
	st 0x4000, 'l'
	st 0x4000, 'o'
	st 0x4000, '!'
	st 0x4000, '\r'
	st 0x4000, '\n'
	
	st8 0x8000, 0x00
loop:
	ld8 0x8000 [f:yes]
	[ex:nonzero] st8 0x4000 [i1:peek]
	pop
	jmp loop
end: