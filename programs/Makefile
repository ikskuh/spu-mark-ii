AS=../assembler/assembler

all: testprogram.hex hello-world.hex

%.hex: %.asm
	$(AS) -o $@ $<
