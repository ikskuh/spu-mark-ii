;
; void puts(char const * string)
;
puts:
	bpget
	spget
	bpset
	
	get -1 ; 0 should be return address
	
puts_loop:
	[i0:peek] ld8 [f:yes]
	[ex:nonzero] out 0x00
	[ex:nonzero] add 1
	[ex:nonzero] jmp puts_loop
	
	bpget
	spset
	bpset
	ret