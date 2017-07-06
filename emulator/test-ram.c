#include "commandline.h"
#include "com.h"

#include "sram.h"

static void command(int * args)
{
	com_puts("RAM-Test...\n\r");
	
	
	mem_write(0xFFFF, 0x88);
	mem_write(0xFF00, 0x11);
	mem_write(0x00FF, 0xBB);
	
	if(mem_read(0xFF00) != 0x11) {
		com_puts("0xFF00 failed\n\r");
	}
	if(mem_read(0x00FF) != 0xBB) {
		com_puts("0x00FF failed\n\r");
	}
	if(mem_read(0xFFFF) != 0x88) {
		com_puts("0xFFFF failed\n\r");
	}
	
	com_puts("Success!\n\r");
}

static void check_address(int * args)
{
	uint16_t addr = args[0];
	for(int i = 0; i < 256; i++) {
		mem_write(addr, 0);
		mem_write(addr, i);
		mem_write(addr, 0);
		mem_write(addr, i);
		mem_write(addr - 1, 0xFF);
		mem_write(addr + 1, 0xFF);
		uint8_t val = mem_read(addr);
		if(val != i) {
			com_puts("Invalid value: ");
			char buf[9];
			com_puts(itoa(i, buf, 2));
			com_puts("≠");
			com_puts(itoa(val, buf, 2));
			com_puts("\n\r");
		}
	}
}


REGISTER_COMMAND(ram, "Tests the SRAM interface.", command, 0)
REGISTER_COMMAND(ta, "Tests the given SRAM address.", check_address, 1)