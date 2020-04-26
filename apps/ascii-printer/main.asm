; Example application
; Repeatedly prints the values between 0x20 and 0x7F to the
; serial port
.org 0x8000
    st 0x4000, '!'
    push 'A'
loop:
    st 0x4000 [i1:peek]
    add 1

    test [i0:peek] 0x80
    [ex:zero] push ' ' [i1:pop]
    [ex:zero] st 0x4000, '\r'
    [ex:zero] st 0x4000, '\n'
    jmp loop
end: