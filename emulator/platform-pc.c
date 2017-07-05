#include "platform.h"
#include <signal.h>
#include <stdbool.h>

extern volatile bool emuBreakToDebugger;

static void sigDebug(int sigNum)
{
	(void)sigNum;
	emuBreakToDebugger = true;
	
	signal(SIGINT, sigDebug);
}

void platform_init()
{
	signal(SIGINT, sigDebug);
}