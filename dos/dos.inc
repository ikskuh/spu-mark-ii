# 1 "<stdin>"
# 1 "<built-in>"
# 1 "<command-line>"
# 31 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 32 "<command-line>" 2
# 1 "<stdin>"
; interrupts.asm main.asm syscall.asm puts.asm itoa.asm
# 1 "macros.inc" 1
# 3 "<stdin>" 2
# 1 "interrupts.asm" 1
.org 0x0000

 jmp main

_interrupts:
 ; 1-8
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4

 ; 9-16
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4

 ; 17-24
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4
 rjmp -4
 jmp syscall ; intr24 → syscall
_interruptsEnd:
# 4 "<stdin>" 2
# 1 "main.asm" 1
main:

 push 16
 push 1337
 push main_buf
 cpget 4 \ jmp itoa
 pop
 pop
 pop

  push main_msg
  cpget 4 \ jmp puts
  pop

 push main_buf
 cpget 4 \ jmp puts
 pop
 out 0x00, '\n'


 setint 1
 int 24, 0xFF

 out 0x00, 'E'

 rjmp -8

main_msg:
.asciiz "Hello, DOS!\r\n"

main_buf:
.asciiz "????????????????"
.align 2
# 5 "<stdin>" 2
# 1 "syscall.asm" 1
syscall:

  push syscall_msg
  cpget 4 \ jmp puts
  pop ; remove arg

 ret

syscall_msg:
.asciiz "[Syscall]"
.align 2
# 6 "<stdin>" 2
# 1 "puts.asm" 1
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
# 7 "<stdin>" 2
# 1 "itoa.asm" 1
;
; void itoa(char * buffer, int number, int radix)
;




itoa: ; ret → 0
 bpget ; bp → 1
 spget
 bpset

 get -1 ; arg buffer → 2
 get -2 ; arg number → 3
 get 2 ; arg buffer string start for reversing is at → 4

 get -3 ; push radix
 st [i1:peek] itoa_radix ; and modify code :)
 st itoa_radix2

 ; if (number < 0) then
 get 3 [f:yes]
 [ex:zero] jmp itoa_iszero
 [ex:gequal] jmp itoa_nonneg
 ; number = -number
 neg
 [i1:peek] set 3
 ; (*buffer++) = '-'
 get 2
 [i0:peek] [i1:arg] st8 '-'
 add 1
 set [i1:peek] 4
 set 2
itoa_nonneg:
 ; endif

 ; do
 ; get 2
itoa_loop:

 ; c = itoa_symbols[number % radix]
 mod [i0:peek] [i1:arg]
itoa_radix:
.dw 10

 add itoa_symbols
 ld8
 get 2
 st8

 ; buffer++
 get 2
 add 1
 set 2

 div [i1:arg] [f:yes]
itoa_radix2:
.dw 10
 ; while (number > 0)

 [ex:greater] jmp itoa_loop
itoa_done_loop:
 pop

 get 2
 [i0:pop] [i1:arg] st8 0x00

 ; Reverse string buffer here

itoa_done:

 bpget
 spset
 bpset
 ret

itoa_iszero:
 get 2
 [i0:peek] [i1:arg] st8 '0'
 add 1
 [i0:pop] [i1:arg] st8 0x00

 bpget
 spset
 bpset
 ret

itoa_symbols:
.ascii "0123456789ABCDEF"
.align 2
itoa_swapbuf1:
.dw 0
itoa_swapbuf2:
.dw 0
# 7 "<stdin>" 2
