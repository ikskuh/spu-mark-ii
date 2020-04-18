.org 0x0000

_start:
    push msg
_loop:
    [i0:peek] ld8 [f:yes]
    [ex:nonzero] st8 0x4000
    [ex:nonzero] add 1
    [ex:nonzero] jmp _loop
    pop
    ret

.org 0x8000
msg:
.asciiz "Hello World\r\n"
.align 2
