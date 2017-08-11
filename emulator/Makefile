FLAGS    = -std=c11 -g -Wall -Wextra -pedantic -I../include
PCFLAGS  = $(FLAGS) -DPLATFORM_PC -DGNU_READLINE -lreadline
AS       = ../assembler/assembler

all: simulator.exe scratchpad.hex

# Set dependencies here
simulator.exe: main.o simulator.o \
	com.o ihex.o debugger.o \
	cpu.o mmu.o bus.o \
	devices/ram.o \
	devices/serial.o \
	devices/rom.o bootrom.o

%.o: %.rom stub.o
	objcopy \
		-I binary $< \
		-O $(shell objdump -f stub.o | grep format | sed "s/.*\s//") $@ \
		-B $(shell objdump -f stub.o | grep arch | sed -E "s/.*:\s((-|[A-Za-z0-9:_])+).*/\1/") \
		--redefine-sym _binary_$(subst .,_,$<)_start=$(basename $@)_start \
		--redefine-sym _binary_$(subst .,_,$<)_end=$(basename $@)_end \
		--redefine-sym _binary_$(subst .,_,$<)_size=$(basename $@)_size

%.exe:
	gcc $(PCFLAGS) -o $@ $^

devices/%.o: devices/%.c
	gcc $(PCFLAGS) -c -o $@ $<

%.o: %.c
	gcc $(PCFLAGS) -c -o $@ $<

%.hex: %.asm
	$(AS) -o $@ $<

%.rom: %.hex
	objcopy -I ihex -O binary $< $@

.PHONY: clean clean-all
.SUFFIXES:

clean-all: clean
	rm *.exe
	
clean:
	rm *.o