.org 0x000
.dw entrypoint  ; Reset
.dw handler.nmi      ; NMI
.dw handler.bus      ; BUS
.dw 0x0000           ; RESERVED
.dw handler.arith    ; ARITH
.dw handler.software ; SOFTWARE
.dw 0x0000           ; RESERVED
.dw handler.irq      ; IRQ

.equ SERIAL_PORT, 0x7FFE
.equ RAM_START,   0x8000

.equ FN_BP_SAVE, 0
.equ FN_RET, 1
.equ FN_ARG_0, 2
.equ FN_ARG_1, 3
.equ FN_ARG_2, 4
.equ FN_ARG_3, 5
.equ FN_ARG_4, 6
.equ FN_ARG_5, 7

handler.nmi:
	st 'N', SERIAL_PORT 
	st 'M', SERIAL_PORT 
	st 'I', SERIAL_PORT 
  iret

handler.bus:
	st 'B', SERIAL_PORT 
	st 'U', SERIAL_PORT 
	st 'S', SERIAL_PORT 
  iret

handler.arith:
	st 'A', SERIAL_PORT
	st 'R', SERIAL_PORT
	st 'I', SERIAL_PORT
	st 'T', SERIAL_PORT
	st 'H', SERIAL_PORT
	iret

handler.software:
	st 'S', SERIAL_PORT
	st 'W', SERIAL_PORT
	st 'I', SERIAL_PORT
	iret

handler.irq:
	st 'I', SERIAL_PORT 
	st 'R', SERIAL_PORT 
	st 'Q', SERIAL_PORT 
	iret

.align 2
entrypoint:
  spset 0x0000
  bpset 0x0000

  push mainMenu.strings.welcome
	call printString
	pop

.align 2
mainMenu:
  st '>', SERIAL_PORT

	push 0
	call getChar

	cmpp 'h'
	[ex:zero] jmp mainMenu.help

	cmpp 'l'
	[ex:zero] jmp mainMenu.loadIhex

	cmpp 'r'
	[ex:zero] jmp mainMenu.runApp

	cmpp 'q'
	[ex:zero] jmp mainMenu.halt
	
	pop ; implement switch here

	push mainMenu.strings.invalidCmd
	call printString
	pop

	jmp mainMenu

mainMenu.help:
	pop ; remove menu char

	push mainMenu.strings.help
	call printString
	pop

	jmp mainMenu

mainMenu.loadIhex:
	pop ; remove menu char

	push mainMenu.strings.pasteIhex
	call printString
	pop

.getStart:
  push 0
	call getChar

	cmpp ':'
	[ex:zero] jmp .loadRecord

	cmpp '\r'
	[ex:nonzero] cmpp '\n'
	[ex:zero] jmp .getStart
	
	replace mainMenu.ihex.invalidChar
	call printString
	pop

	jmp mainMenu

.loadRecord:
	pop ; remove ':'

	; TODO: Implement hex loading

.copy_loop:
	push 0
	call getHexByte
	st SERIAL_PORT

	jmp .copy_loop

mainMenu.runApp:
	pop ; remove menu char

	push mainMenu.strings.runAppIntro
	call printString
	pop
	
	call 0x8000 ; defined entry pointer

	jmp mainMenu

mainMenu.halt:
	pop ; remove menu char

	push mainMenu.strings.haltMessage
	call printString
	pop

	halt ; exit

	jmp mainMenu

; fn getChar() u8
.align 2
getChar:
	bpget
	spget
	bpset

.waitLoop:
  ld SERIAL_PORT [f:yes]
  [ex:less] pop
	[ex:less] jmp .waitLoop

	set FN_ARG_0 ; this is the return value

	bpget
	spset
	bpset
	ret

; fn getHexByte() !u8
.align 2
getHexByte:
	bpget
	spget
	bpset

	; fetch upper nibble
	push 0
	call getChar
	call hexToValue
	[ex:less] jmp .done ; handle error
	lsl
	lsl
	lsl
	lsl

	; fetch lower nibble
	push 0
	call getChar
	call hexToValue
	[ex:less] jmp .done ; handle error

	; merge upper and lower nibble
	or 
	set FN_ARG_0 [f:yes] ; reset "negative" flag

.done:
	bpget
	spset
	bpset
	ret

; fn getHexWord() !u8
.align 2
getHexWord:
	bpget
	spget
	bpset

	; fetch upper byte
	push 0 
	call getHexByte
	[ex:less] jmp .done
	bswap

	; fetch lower byte
	push 0
	call getHexByte
	[ex:less] jmp .done

	or ; merge upper and lower byte
	set FN_ARG_0

	push [out:discard] [f:yes] 0 ; reset "negative" flag

.done:
	bpget
	spset
	bpset
	ret

; fn hexToValue(ascii: u8) !u8
.align 2
hexToValue:
	bpget
	spget
	bpset

	; 0 … 9 ( 48 …  57 ) => 0 … 9
	; A … F ( 65 …  70 ) => 10 … 15
	; a … f ( 97 … 102 ) => 10 … 15

	get FN_ARG_0

	sub '0' [f:yes]
	[ex:less] jmp .failure ; less than '0'

	cmpp 10
	[ex:less] jmp .parseBelow10
	
	sub 'A'-'0' [f:yes]
	[ex:less] jmp .failure ; between 58 and 64
	
	cmpp 6
	[ex:less] jmp .parseUpper

	sub 'a'-'A' [f:yes]
	[ex:less] jmp .failure ; between 71 and 96

	cmpp 6
	[ex:less] jmp .parseUpper

.failure:
  set FN_ARG_0, 0xFFFF [f:yes] ; store result, set "negative" flag
	jmp .done

.parseUpper:
	add 10 ; move current value up to A…F

.parseBelow10:
	set FN_ARG_0 [f:yes] ; store result, reset "negative" flag

.done:
	bpget
	spset
	bpset
	ret

; fn printString(str: [*:0]const u8) void
.align 2
printString:
	bpget
	spget
	bpset
	get FN_ARG_0

.loop:
  ld8 [i0:peek] [f:yes]
	[ex:zero] jmp .done
  st SERIAL_PORT
	add 1
	jmp .loop
.done:
	bpget
	spset
	bpset
	ret

mainMenu.strings.welcome:
	.asciiz "Welcome to the SPU Mark II demo application!\r\n\r\nPress 'h' for help!\r\n"

mainMenu.strings.invalidCmd:
.asciiz "Invalid selection!\r\n"

mainMenu.strings.help:
.ascii "help\r\n"
.ascii "h: print this help\r\n"
.ascii "l: load ihex binary\r\n"
.ascii "r: run code (jump to 0x8000)\r\n"
.ascii "q: quit (and halt the CPU)\r\n"
.db 0

mainMenu.strings.pasteIhex:
.ascii "load ihex binary\r\n"
.ascii "Send the ihex file now. Terminate with :00000001FF\r\n"
.db 0

mainMenu.strings.runAppIntro:
.asciiz "run app\r\nJumping to 0x8000...\r\n"

mainMenu.strings.haltMessage:
.asciiz "quit (and halt cpu)\r\n"

mainMenu.ihex.invalidChar:
.asciiz "received invalid char\r\n"