; comment

label:
	op
	op arg
	op arg1, arg2
	
	op (formula)
	op (formula), (formula)

.org    0
.db     0
.dw     0
.align  4
.ascii  "Hello, World!"
.asciiz "Hello, World!"

----------------------------------------

Mögliche Modifikatoren für Befehle
	exec   ∊ { always, never, zero, nonzero, less, greater, lequal, gequal }
	input0 ∊ { zero, arg, peek, pop }
	input1 ∊ { zero, arg, peek, pop }
	cmd    ∊ { copy, get, set, input, output, add, mul, int, … }
	output ∊ { discard, push, jump, rjmp }
	flags  ∊ { 0, 1 }

[ex:less]
[i0:zero]
[i1:arg]
[cmd:copy]
[out:rjmp]
[f:yes]

