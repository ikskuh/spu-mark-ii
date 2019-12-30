#!/bin/bash


for i in {0..63}; do
	echo $i | sed -E 's/(.*)/#{top.testbench.simulated_ram[\1][15:0]} top.testbench.simulated_ram[\1][15] top.testbench.simulated_ram[\1][14] top.testbench.simulated_ram[\1][13] top.testbench.simulated_ram[\1][12] top.testbench.simulated_ram[\1][11] top.testbench.simulated_ram[\1][10] top.testbench.simulated_ram[\1][9] top.testbench.simulated_ram[\1][8] top.testbench.simulated_ram[\1][7] top.testbench.simulated_ram[\1][6] top.testbench.simulated_ram[\1][5] top.testbench.simulated_ram[\1][4] top.testbench.simulated_ram[\1][3] top.testbench.simulated_ram[\1][2] top.testbench.simulated_ram[\1][1] top.testbench.simulated_ram[\1][0]/g' >> ../hw-impl/testbench.gtkw
done
