
SOURCES=$(addprefix src/,debug-port-in.vhd debug-port-out.vhd sram-controller.vhd uart_sender.vhd uart_receiver.vhd register-ram.vhd fifo.vhd serial-port.vhd cpu.vhd builtin-rom.vhd rom.vhd soc.vhd root.vhd testbench_fifo.vhd testbench_spu.vhd)

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
	ghdl -r $< --wave=$@ --stop-time=150us

clean: $(OBJS)
	rm $^

.PHONY: clean
.SUFFIXES: