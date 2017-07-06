
main:
	push 0
outer_loop:
	push 10000
inner_loop:
	sub 1 [f:yes]
	[ex:nonzero] jmp inner_loop
	pop
	add 1
	jmp outer_loop