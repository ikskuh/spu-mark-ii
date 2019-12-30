
SOURCES=$(addprefix src/,cpu.vhd builtin-rom.vhd testbench.vhd)

OBJS=$(notdir $(SOURCES:.vhd=.o))

all: testbench.ghw clean

testbench: $(OBJS)
	ghdl -e --std=08 testbench

%.o: src/%.vhd
	ghdl -a --std=08 $^

%.vcd: %
	ghdl -r $< --vcd=$@ --stop-time=5000ns

%.ghw: %
	ghdl -r $< --wave=$@ --stop-time=5000ns

clean: $(OBJS)
	rm $^

.PHONY: clean
.SUFFIXES: