#include <stdbool.h>
#include <stdlib.h>

#include "sram.h"
#include "io.h"
#include "ihex.h"
#include "emulator.h"
#include "spu-2.h"

int main()
{
	mem_init();
	emu_init();
	io_init();
	
	ihex_load();
	
	while(true)
	{
		emu_step();
	}
	
	return 0;
}