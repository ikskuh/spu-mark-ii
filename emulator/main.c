#include <stdbool.h>
#include <stdlib.h>

#include "sram.h"
#include "io.h"
#include "ihex.h"
#include "emulator.h"
#include "spu-2.h"
#include "trace.h"

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
	mem_init();
	emu_init();
	io_init();
	
	trace_init();
	
	ihex_load();
	
	while(true)
	{
		emu_step();
	}
	
	return 0;
}