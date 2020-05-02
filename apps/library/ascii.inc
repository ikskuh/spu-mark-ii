; Provides common ASCII control characters as constants

.equ ASCII_NUL, 0   ; null
.equ ASCII_SOH, 1   ; start of heading
.equ ASCII_STX, 2   ; start of text
.equ ASCII_ETX, 3   ; end of text
.equ ASCII_EOT, 4   ; end of transmission
.equ ASCII_ENQ, 5   ; enquiry
.equ ASCII_ACK, 6   ; acknowledge
.equ ASCII_BEL, 7   ; bell
.equ ASCII_BS,  8   ; backsace
.equ ASCII_TAB, 9   ; horizontal tabulator
.equ ASCII_LF,  10  ; line feed
.equ ASCII_VT,  11  ; vertical tabulator
.equ ASCII_FF,  12  ; form feed
.equ ASCII_CR,  13  ; carriage return
.equ ASCII_SO,  14  ; shift out
.equ ASCII_SI,  15  ; shift in
.equ ASCII_DLE, 16  ; data link escape
.equ ASCII_DC1, 17  ; device control 1
.equ ASCII_DC2, 18  ; device control 2
.equ ASCII_DC3, 19  ; device control 3
.equ ASCII_DC4, 20  ; device control 4
.equ ASCII_NAK, 21  ; negative acknowledge
.equ ASCII_SYN, 22  ; synchronous idle
.equ ASCII_ETB, 23  ; end of transmission block
.equ ASCII_CAN, 24  ; cancel
.equ ASCII_EM,  25  ; end of medium
.equ ASCII_SUB, 26  ; substitute
.equ ASCII_ESC, 27  ; escape
.equ ASCII_FS,  28  ; file separator
.equ ASCII_GS,  29  ; group separator
.equ ASCII_RS,  30  ; record separator
.equ ASCII_US,  31  ; unit separator
.equ ASCII_RUB, 127 ; rub out (what happens when you press the '<=' button that is called backspace