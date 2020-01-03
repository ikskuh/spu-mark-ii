.org 0x0000
	spset 0x8020                ; 0000   3C08 8020        Initialize Stack Pointer 16 elements into RAM
	st 0x4000, '!'              ; 0004   1428 4000 0021
	push 'A'                    ; 000A   0108 0041
loop:	
	st 0x4000 [i1:peek]         ; 000E   1448 4000
	push 1                      ; 0012   0108 0001
	add                         ; 0016   4178 
	test [i0:peek] 0x80         ; 0018   44b0 0080
	[ex:zero] push ' ' [i1:pop] ; 001C   0169 0020        replace stack top with 0x20 (space)
	[ex:zero] st 0x4000, '\r'   ; 0020   1429 4000 000d
	[ex:zero] st 0x4000, '\n'   ; 0026   1429 4000 000a
	jmp loop                    ; 002C   0208 000e
end: