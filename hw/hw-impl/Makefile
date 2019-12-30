
SOURCES=$(shell find src -name "*.vhd")

OBJS=$(notdir $(SOURCES:.vhd=.o))

all: testbench.ghw

testbench: $(OBJS)
	ghdl -e --std=08 testbench

%.o: src/%.vhd
	ghdl -a --std=08 $^

%.vcd: %
	ghdl -r $< --vcd=$@ --stop-time=5000ns

%.ghw: %
	ghdl -r $< --wave=$@ --stop-time=5000ns

clean:
	rm *.o

.PHONY: clean
.SUFFIXES: