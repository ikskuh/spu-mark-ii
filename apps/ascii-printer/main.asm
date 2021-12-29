; Example application
; Repeatedly prints the values between 0x20 and 0x7F to the
; serial port

.include "../library/bios.inc"

.org APP_START
    st UART_TXD, '!'
    push 'A'
loop:
    st UART_RXD [i1:peek]
    add 1

    cmp [i0:peek] 0x80
    [ex:zero] push ' ' [i1:pop]
    [ex:zero] st UART_TXD, '\r'
    [ex:zero] st UART_TXD, '\n'
    jmp loop
end: