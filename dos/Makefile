AS=../assembler/assembler
SIM=../emulator/simulator.exe

all: dos.hex

dos.hex: dos.inc
	$(AS) -s -o $@ $<

dos.inc: interrupts.asm main.asm syscall.asm puts.asm
	echo '; ' $^ > $@.proto
	for i in $^; do echo "#include \"$$i\"" >> $@.proto; done
	cat $@.proto | cpp > $@
	rm $@.proto

run: dos.hex
	cat $< | $(SIM)
	
.PHONY: run