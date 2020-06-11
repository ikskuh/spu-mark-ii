.org 0x0000

  bpset 0x0000
  spset 0x0000
  
  
  
  push msg_hello
  ipget 2
  jmp serial_puts
  pop
  
  push 0x10

mini_loop:
  push 0x0000
  ipget 2
  jmp sleep
  pop
  
  sub 1 [f:yes]
  [ex:nonzero] jmp mini_loop
  pop
  
  push msg_byte
  ipget 2
  jmp serial_puts
  pop
  
.dw 0x8000 ; invalid opcode
  
msg_hello:
.asciiz "Hello, World!\r\n"
msg_byte:
.asciiz "Goodbye, Emulator!\r\n"

; fn(str: [*:0]const u8) void
; prints a string to the serial terminal
.align 2
serial_puts:
	bpget
	spget
	bpset
	
	get 2 ; arg 1
.puts_loop:
	ld8 [i0:peek] [f:yes]
	[ex:nonzero] st8 0x4000
	[ex:nonzero] add 1
	[ex:nonzero] jmp .puts_loop
	pop

	bpget
	spset
	bpset
	ret
  
  
sleep:
	bpget
	spget
	bpset
  
  get 0-2
  
.loop:
  sub 1 [f:yes]
  nop
  nop
  [ex:nonzero] jmp .loop
  pop
  
	bpget
	spset
	bpset
	ret