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


REGISTER_COMMAND(
	ram,
	"Tests the SRAM interface.",
	command, 0)