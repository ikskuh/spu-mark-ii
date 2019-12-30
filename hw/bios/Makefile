
AS=../../assembler/assembler

all: ../hw-impl/src/builtin-rom.vhd

../hw-impl/src/builtin-rom.vhd: main.bin make-vhd
	./make-vhd $@ $<

%.vhd: %.bin make-vhd
	./make-vhd $@ $<

%.bin: %.hex
	objcopy -I ihex -O binary $< $@

%.hex: %.asm
	$(AS) -o $@ $<

make-vhd: make-vhd.zig
	zig build-exe $^
