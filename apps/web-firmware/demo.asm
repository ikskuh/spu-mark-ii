.equ ROM_START,   0x0000
.equ SERIAL_PORT, 0x7FFE
.equ RAM_START,   0x8000

.org RAM_START

entry_point:

  push message

.loop:
  ld8 [i0:peek] [f:yes]
	[ex:zero] jmp .done
  st SERIAL_PORT
	add 1
	jmp .loop
.done:
  pop ; remove 0 byte
  pop ; remove address

  ret ; return to bios

message:
.asciiz "Hello, World!\r\n"