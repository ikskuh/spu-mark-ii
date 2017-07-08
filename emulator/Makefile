TTY=/dev/ttyUSB0
MCU=atmega32
FREQ=20000000

FLAGS    = -g -Wall -Wextra -pedantic -I../include
PCFLAGS  = $(FLAGS) -Dmain=sim_main -DPLATFORM_PC
AVRFLAGS = $(FLAGS) -Os -mmcu=$(MCU) -DF_CPU=$(FREQ)ULL  -DPLATFORM_AVR

ifeq ($(TRACE) , 1)
PCFLAGS += -DTRACE
endif

ifeq ($(GNURL) , 1)
PCFLAGS += -DGNU_READLINE -lreadline
endif

all: main.hex ramtest.hex simulator.exe

# Set dependencies here
ramtest.elf: avr-ramtest.o avr-usart.o avr-sram.o
devtest.elf: avr-devtest.o avr-usart.o \
	avr-sram.o avr-com.o \
	avr-commandline.o avr-readline.o \
	avr-test-ram.o \
	avr-cmd-spi.o avr-spi.o \
	avr-cmd-i2c.o avr-i2csoft.o
main.elf: avr-main.o avr-usart.o avr-sram.o \
	avr-io.o avr-emulator.o avr-ihex.o \
	avr-trace.o avr-debugger.o avr-readline.o \
	avr-platform-avr.o
display.elf: avr-display-driver.o avr-usart.o \
	avr-spi.o
simulator.exe: pc-main.o pc-simulator.o \
	pc-emulator.o pc-ihex.o pc-trace.o \
	pc-itoa.o pc-platform-pc.o pc-debugger.o \
	pc-readline.o

%.exe:
	gcc $(PCFLAGS) -o $@ $^

%.hex: %.elf
	avr-objcopy $< -O ihex $@

%.elf:
	avr-gcc $(AVRFLAGS) -o $@ $^
	avr-size -C --mcu=$(MCU) $@

avr-%.o: %.c
	avr-gcc $(AVRFLAGS) -std=c11 -c -o $@ $<

avr-%.o: %.cpp
	avr-g++ $(AVRFLAGS) -std=c++11 -c -o $@ $<

pc-%.o: %.c
	gcc $(PCFLAGS) -std=c11 -c -o $@ $<
	
%\:flash: %.hex
	avrdude -p $(MCU) -c stk500v2 -P $(TTY) -e -U flash:w:$<
	
.PHONY: atmega32-init clean clean-all
.SUFFIXES:

clean-all: clean
	rm *.hex *.elf *.exe
	
clean:
	rm *.o

atmega32-init:
	avrdude -p atmega32 -P $(TTY) -c stk500v2 -U lfuse:w:0x4f:m -U hfuse:w:0xd1:m
	