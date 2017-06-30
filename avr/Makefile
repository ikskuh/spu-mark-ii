TTY=/dev/ttyUSB0
MCU=atmega32
FREQ=20000000

FLAGS= -g -Wall -Wextra -pedantic -O3 -mmcu=$(MCU) -DF_CPU=$(FREQ)ULL -I../include

all: ramtest.hex main.hex

# Set dependencies here
ramtest.elf: ramtest.o usart.o sram.o

main.elf: main.o usart.o sram.o io.o emulator.o


%: %.hex
	
%.hex: %.elf
	avr-objcopy $< -O ihex $@

%.elf: %.o
	avr-gcc $(FLAGS) -o $@ $^
	avr-size -C --mcu=$(MCU) $@

%.o: %.c
	avr-gcc $(FLAGS) -std=c11 -c -o $@ $<

%.o: %.cpp
	avr-g++ $(FLAGS) -std=c++11 -c -o $@ $<

%\:flash: %.hex
	avrdude -p $(MCU) -c stk500v2 -P $(TTY) -e -U flash:w:$<
	
.PHONY: atmega32-init clean

clean:
	rm *.hex *.elf *.o

atmega32-init:
	avrdude -p atmega32 -P $(TTY) -c stk500v2 -U lfuse:w:0x4f:m -U hfuse:w:0xd1:m