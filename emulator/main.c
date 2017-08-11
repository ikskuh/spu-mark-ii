#include <stdbool.h>
#include <stdlib.h>

#include <spu-2.h>
#include "cpu.h"
#include "bus.h"
#include "mmu.h"

#include "com.h"
#include "debugger.h"
#include "platform.h"

volatile bool emuBreakToDebugger = false;

int main(PLATFORM_MAIN)
{
	bus_init();
	mmu_init();
	cpu_init();
	com_init();
	dbg_init();
	
	platform_init(PLATFORM_ARGS);

	while(true)
	{
		if(emuBreakToDebugger || dbg_tick()) {
			dbg_enter();
			emuBreakToDebugger = false;
		}
		cpu_step();
	}
	
	return 0;
}