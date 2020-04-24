
SOURCES=$(addprefix ../src/,vga.vhd debug-port-in.vhd debug-port-out.vhd sram-controller.vhd uart_sender.vhd uart_receiver.vhd register-ram.vhd fifo.vhd serial-port.vhd cpu.vhd builtin-rom.vhd rom.vhd soc.vhd root.vhd testbench_fifo.vhd testbench_spu.vhd testbench_vga.vhd)

OBJS=$(addprefix obj/,$(notdir $(SOURCES:.vhd=.o)))

TIME?=2500us

all: testbench_spu.ghw testbench_fifo.ghw testbench_vga.ghw

obj/testbench_spu: $(OBJS)
	cd obj; ghdl -e --std=08 testbench_spu

obj/testbench_fifo: $(OBJS)
	cd obj; ghdl -e --std=08 testbench_fifo

obj/testbench_vga: $(OBJS)
	cd obj; ghdl -e --std=08 testbench_vga

obj/%.o: ../src/%.vhd
	cd obj; ghdl -a --std=08 ../$^

%.vcd: %
	ghdl -r $< --vcd=$@ --stop-time=50us

%.ghw: obj/%
	cd obj; ghdl -r $(notdir $<) --wave=../$@ --stop-time=$(TIME)

clean: $(OBJS)
	rm $^

.PHONY: clean
.SUFFIXES: