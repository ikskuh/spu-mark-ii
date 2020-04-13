PROGRAM=debug-avr
F_CPU=16000000
MCU=atmega328p
PORT?=/dev/ttyUSB0
PROG?=arduino
PROGBAUD?=57600
APPBAUD=19200

DEFINES=F_CPU=$(F_CPU)ULL UART_BAUD=$(APPBAUD)ULL
FLAGS=-mmcu=$(MCU)
CFLAGS=$(FLAGS) $(addprefix -D,$(DEFINES)) -Os
LFLAGS=$(FLAGS)

CC=avr-gcc
LD=avr-gcc

SOURCES=main.c
OBJS=$(SOURCES:.c=.o)

all: $(PROGRAM).elf

hex: $(PROGRAM).hex

help:
	@echo "Available commands:"
	@echo "$(MAKE)"
	@echo "  - Builds $(PROGRAM).elf"
	@echo ""
	@echo "$(MAKE) hex"
	@echo "  - Builds $(PROGRAM).hex"
	@echo ""
	@echo "$(MAKE) flash"
	@echo "  - Compiles $(PROGRAM).hex and flashes it to $(PROG) at port $(PORT)"
	@echo ""
	@echo "$(MAKE) terminal"
	@echo "  - Starts up picocom on $(PORT) with $(APPBAUD), 8N1"
	@echo ""
	@echo "$(MAKE) clean"
	@echo "  - Cleans up all build artifacts"
	@echo ""
	@echo "$(MAKE) init-vscode"
	@echo "  - Initializes a VS Code project and creates the folder .vscode"

clean:
	rm -f $(OBJS) $(PROGRAM).hex $(PROGRAM).elf

flash: $(PROGRAM).hex
	avrdude -P $(PORT) -c $(PROG) -b $(PROGBAUD) -p $(MCU) -e -U flash:w:$<

terminal:
	picocom --baud $(APPBAUD) $(PORT)

init-vscode:
	mkdir -p .vscode

	echo '{"version":"2.0.0","tasks":[{"type":"shell","label":"build","command":"/usr/bin/make","args":[],"presentation":{"echo":false,"reveal":"silent","focus":false,"panel":"dedicated","showReuseMessage":false,"clear":true},"problemMatcher":"$$gcc","group":"build"},{"type":"shell","label":"flash","command":"/usr/bin/make","args":["flash"],"presentation":{"echo":false,"reveal":"always","focus":false,"panel":"dedicated","showReuseMessage":false,"clear":true},"problemMatcher":"$$gcc","group":"build"}]}' > .vscode/tasks.json

	echo '{"configurations":[{"name": "AVR","includePath":["/usr/avr/include"],"defines":[' > .vscode/c_cpp_properties.json
	avr-gcc $(CFLAGS) -c -dM -E - < /dev/null | grep -E '#define ([A-Za-z0-9_]+)[[:space:]]+([A-Za-z0-9\+\*\_]+)' | sort | sed -E 's/^#define ([A-Za-z0-9_]+)[[:space:]]+(.*)/"\1=\2",/' >> .vscode/c_cpp_properties.json
	echo '"_DUMMY_=0"],"compilerPath": "/usr/bin/avr-gcc","cStandard":"c99","cppStandard":"c++11","intelliSenseMode":"gcc-x86"}],"version":4}' >> .vscode/c_cpp_properties.json

$(PROGRAM).elf: $(OBJS)
	$(LD) $(LFLAGS) -o $@ $^

%.hex: %.elf
	avr-objcopy -O ihex $< $@

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

.PHONY: clean flash init-vscode help hex terminal
.SUFFIXES: