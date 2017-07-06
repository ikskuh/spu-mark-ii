#include "trace.h"
#include "com.h"
#include <stdlib.h>
#include <stdio.h>

#ifndef PLATFORM_AVR
#include <string.h>
extern int _argc;
extern char ** _argv;
#endif

#ifdef TRACE

static char buffer[64];
static bool enabled = false;

char *  itoa ( int value, char * str, int base );

void trace_init()
{
#ifdef PLATFORM_AVR
	enabled = true;
#else
	for(int i = 1; i < _argc; i++) {
		enabled |= !strcmp(_argv[i], "-t");
		enabled |= !strcmp(_argv[i], "--trace");
	}
#endif
}

void trace_stack(word_t * stack, int bp, int count)
{
	if(!enabled) return;
	com_puts("STACK [");
	for(int i = 0; i < count; i++) {
		com_puts(" ");
		if(i == bp) {
			com_putc('*');
		}
		com_puts(itoa(stack[i], buffer, 10));
	}
	com_puts(" ]\n\r");
}

void trace_instr(uint16_t addr, uint16_t instr, uint16_t top, int flags, bool exec)
{
	if(!enabled) return;
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
	if(!enabled) return;
	com_puts(" → ");
	com_puts(itoa(result, buffer, 16));
	com_puts("\n\r");
	com_getc();
}


void trace_intr(uint16_t intr)
{
	if(!enabled) return;
	com_puts("INTERRUPT: ");
	com_puts(itoa(intr, buffer, 16));
	com_puts("\n\r");
	com_getc();
}

#endif