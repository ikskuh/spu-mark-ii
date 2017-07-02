; 
; Hello World-Program
;
; Outputs 'Hello!\n\r', then
; echoes all serial input.
;
_start:
	push '\r'
	push '\n'
	push '\!'
	push '\o'
	push '\l'
	dup
	push '\e'
	push '\H'
_output:
	out 0
	out 0
	out 0
	out 0
	out 0
	out 0
	out 0
	out 0
_loop:
	in 0
	out 0
	jmp _loop
	