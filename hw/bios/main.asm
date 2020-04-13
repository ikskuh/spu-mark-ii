.org 0x0000
	spset 0x6020    ; 16 Element Stack
	st 0x4000, '!'  ; Startup Message
loop:
	st8 0x4000, 'A'    ; output 'A'
	st8 0x8000, 0xFF   ; store 0xFF
	st8 0x4000, 'B'    ; output 'B'
	ld8 0x8000        ; load 'X'
	st8 0x4000        ; output to serial

	push 100
waitloop:
	sub 1 [f:yes]
	[ex:nonzero] jmp waitloop
	pop

	jmp loop
end: