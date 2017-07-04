# 1 "<stdin>"
# 1 "<built-in>"
# 1 "<command-line>"
# 31 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 32 "<command-line>" 2
# 1 "<stdin>"
; interrupts.asm main.asm syscall.asm puts.asm
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

 ; push main_msg
 ; cpget 4 \ jmp puts
 ; pop

 out 0x00, 'S'

 setint 1
 int 24

 out 0x00, 'E'

 rjmp -4

main_msg:
.asciiz "Hello, DOS!\r\n"
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
# 6 "<stdin>" 2
