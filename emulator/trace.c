#include "trace.h"
#include "com.h"
#include <stdlib.h>
#include <stdio.h>

#ifdef TRACE

static char buffer[64];

char *  itoa ( int value, char * str, int base );

void trace_instr(uint16_t addr, uint16_t instr, uint16_t top, int flags, bool exec)
{
	com_puts("TRACE: CP=");
	com_puts(itoa(addr, buffer, 16));
	com_puts(", INSTR=");
	com_puts(itoa(instr, buffer, 16));
	com_puts(", TOP=");
	com_puts(itoa(top, buffer, 16));
	com_puts(", FLAGS=");
	if(flags & 1) com_putc('Z');
	if(flags & 2) com_putc('N');
	if(flags & 4) com_putc('I');
	com_puts(", EXEC=");
	if(exec) {
		com_puts("YES");
	} else {
		com_puts("NO\n\r");
		com_getc();
	}
}

void trace_result(uint16_t result)
{
	com_puts(" → ");
	com_puts(itoa(result, buffer, 16));
	com_puts("\n\r");
	com_getc();
}

#endif