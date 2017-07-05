#include <stdbool.h>
#include <stdlib.h>

#include "sram.h"
#include "io.h"
#include "ihex.h"
#include "emulator.h"
#include "spu-2.h"
#include "trace.h"
#include "debugger.h"
#include "platform.h"

volatile bool emuBreakToDebugger = false;

int main()
{
	platform_init();
	mem_init();
	emu_init();
	io_init();
	dbg_init();
	
	trace_init();
	
	// Before execution, break into the debugger
#if __AVR_GCC__
	emuBreakToDebugger = true;
#endif

	while(true)
	{
		if(emuBreakToDebugger || dbg_tick()) {
			dbg_enter();
			emuBreakToDebugger = false;
		}
		emu_step();
	}
	
	return 0;
}