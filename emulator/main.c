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

#ifdef __AVR_GCC__
int main()
{
#else
int _argc;
char ** _argv;

int main(int argc, char ** argv)
{
	_argc = argc;
	_argv = argv;
#endif
	platform_init();
	mem_init();
	emu_init();
	io_init();
	dbg_init();
	
	trace_init();
	
	// Before execution, break into the debugger
	emuBreakToDebugger = true;
	
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