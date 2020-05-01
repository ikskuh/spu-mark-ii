


; This is the location of `puts(char * str)` in the ROM.
; We can use this to clarify where we're jumping to
.equ ROM_PUTS, 0x0006


; Entry point for applications, BIOS will jump here after
; loading the application to memory.
.equ APP_START, 0x8000
