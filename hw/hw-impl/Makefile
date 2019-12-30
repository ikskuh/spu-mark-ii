
SOURCES=$(shell find src -name "*.vhd")

OBJS=$(notdir $(SOURCES:.vhd=.o))

all: testbench.ghw

testbench: $(OBJS)
	ghdl -e testbench

%.o: src/%.vhd
	ghdl -a $^

%.vcd: %
	ghdl -r $< --vcd=$@ --stop-time=1000ns

%.ghw: %
	ghdl -r $< --wave=$@ --stop-time=1000ns

clean:
	rm *.o

.PHONY: clean
.SUFFIXES: