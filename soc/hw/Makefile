
SOURCES=$(addprefix src/,vga.vhd debug-port-in.vhd debug-port-out.vhd sram-controller.vhd uart_sender.vhd uart_receiver.vhd register-ram.vhd fifo.vhd serial-port.vhd cpu.vhd builtin-rom.vhd rom.vhd soc.vhd root.vhd testbench_fifo.vhd testbench_spu.vhd testbench_vga.vhd)

OBJS=$(notdir $(SOURCES:.vhd=.o))

TIME?=2500us

all: testbench_spu.ghw testbench_fifo.ghw testbench_vga.ghw

testbench_spu: $(OBJS)
	ghdl -e --std=08 testbench_spu

testbench_fifo: $(OBJS)
	ghdl -e --std=08 testbench_fifo

testbench_vga: $(OBJS)
	ghdl -e --std=08 testbench_vga

%.o: src/%.vhd
	ghdl -a --std=08 $^

%.vcd: %
	ghdl -r $< --vcd=$@ --stop-time=50us

%.ghw: %
	ghdl -r $< --wave=$@ --stop-time=$(TIME)

clean: $(OBJS)
	rm $^

.PHONY: clean
.SUFFIXES: