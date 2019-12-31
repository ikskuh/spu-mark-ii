
SOURCES=$(addprefix src/,fifo.vhd cpu.vhd builtin-rom.vhd testbench_fifo.vhd testbench_spu.vhd)

OBJS=$(notdir $(SOURCES:.vhd=.o))

all: testbench_spu.ghw testbench_fifo.ghw clean

testbench_spu: $(OBJS)
	ghdl -e --std=08 testbench_spu

testbench_fifo: $(OBJS)
	ghdl -e --std=08 testbench_fifo

%.o: src/%.vhd
	ghdl -a --std=08 $^

%.vcd: %
	ghdl -r $< --vcd=$@ --stop-time=50us

%.ghw: %
	ghdl -r $< --wave=$@ --stop-time=50us

clean: $(OBJS)
	rm $^

.PHONY: clean
.SUFFIXES: