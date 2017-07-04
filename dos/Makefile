AS=../assembler/assembler
SIM=../emulator/simulator.exe

all: dos.hex

dos.hex: dos.inc
	echo -e "\033[31;1mAssemble...\033[0m"
	$(AS) -s -o $@ $<

dos.inc: interrupts.asm main.asm syscall.asm puts.asm
	echo -e "\033[31;1mPack...\033[0m"
	echo '; ' $^ > $@.proto
	echo '#include "macros.inc"' >> $@.proto
	for i in $^; do echo "#include \"$$i\"" >> $@.proto; done
	cat $@.proto | cpp > $@
	rm $@.proto

run: dos.hex
	echo -e "\033[31;1mRun...\033[0m"
	cat $< | $(SIM)
	
trace: dos.hex
	echo -e "\033[31;1mTrace...\033[0m"
	cat $<
	$(SIM) --trace
	
.PHONY: run trace