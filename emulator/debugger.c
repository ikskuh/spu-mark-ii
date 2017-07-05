#include "debugger.h"
#include "emulator.h"
#include "com.h"
#include "ihex.h"
#include "sram.h"
#include "minireadline.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

char *  itoa ( int value, char * str, int base );

static char buffer[64];
static volatile bool quit = false;

#ifndef __AVR_GCC__
static void cmd_quit(int * args);
#endif

static void cmd_run(int * args);
static void cmd_step(int * args);
static void cmd_load(int * args);
static void cmd_read8(int * args);
static void cmd_read16(int * args);
static void cmd_write8(int * args);
static void cmd_write16(int * args);
static void cmd_breakpoint(int * args);
static void cmd_jump(int * args);
static void cmd_push(int * args);
static void cmd_pop(int * args);
static void cmd_info(int * args);
static void cmd_reset(int * args);
static void cmd_help(int * args);

struct pattern
{
	char const * pattern;
	int argc;
	void (*execute)(int * args);
	char const * description;
};

static struct pattern commands[] = 
{
#ifndef __AVR_GCC__
	// PC commands
	{ "q",    0, cmd_quit,       "Stops the simulation."},
#endif
	{ "h",    0, cmd_help,       "Lists this help."},
	
	{ "r",    0, cmd_run,        "Resumes execution." },
	{ "s",    0, cmd_step,       "Executes a single step." },
	
	{ "l",    0, cmd_load,       "Starts the IHEX loader." },
	
	{ "rb",   1, cmd_read8,      "Reads a byte from memory." },
	{ "rw",   1, cmd_read16,     "Reads a word from memory." },
	{ "wb",   2, cmd_write8,     "Writes a byte into memory." },
	{ "ww",   2, cmd_write16,    "Writes a word into memory." },
	
	{ "bp",   1, cmd_breakpoint, "Enables/disables a breakpoint." },
	
	{ "jp",   1, cmd_jump,       "Jumps to the first argument." },
	{ "push", 1, cmd_push,       "Pushes the first argument onto the stack." },
	{ "pop",  0, cmd_pop,        "Pops the top value from the stack and displays it."},
	
	{ "i",    0, cmd_info,       "Prints information about the CPU state."},
	{ "x",    0, cmd_reset,      "Resets the CPU."},
	
	{ NULL,   0,  NULL,          NULL },
};

static void cmd_info(int * args)
{
	(void)args;
	com_puts(  "SP="); com_puts(itoa(regSP, buffer, 10));
	com_puts("\tBP="); com_puts(itoa(regBP, buffer, 10));
	com_puts("\tCP="); com_puts(itoa(regCP, buffer, 16));
	com_puts("\n\r[");
	for(int i = 0; i < regSP; i++) {
		com_puts(" ");
		if(i == regBP) {
			com_putc('*');
		}
		com_puts(itoa(stack[i], buffer, 10));
	}
	com_puts(" ]\n\r");
}

static uint16_t breakpoints[8];

bool dbg_tick()
{
	for(int i = 0; i < 8; i++) {
		if(regCP == breakpoints[i]) {
			return true;
		}
	}
	return false;
}

void dbg_init()
{
	for(int i = 0; i < 8; i++) {
		breakpoints[i] = 0xFFFF;
	}
}

void dbg_enter()
{
	quit = false;
	cmd_info(NULL);
	while(quit == false)
	{
		char * linebuf = READLINE("(dbg) ");
		
		char const * cmd = linebuf;
		int arguments[4];
		int argc = 0;
		do
		{
			char * p = linebuf;
			while(isalnum(*p)) p++;
			if(*p == 0) break;
			*p++ = 0;
			// start parsing args
			while(*p)
			{
				while(isblank(*p)) p++;
				char * str = p;
				while(*p == '$' || isalnum(*p)) p++;
				if(*str == '$') {
					arguments[argc++] = strtol(str + 1, NULL, 16);
				} else {
					arguments[argc++] = strtol(str, NULL, 10);
				}
				if(*p == 0) break;
				*p++ = 0;
			}
		} while(false);
		
		int sel;
		for(sel = 0; commands[sel].pattern; sel++)
		{
			if(strcmp(commands[sel].pattern, cmd)) {
				continue;
			}
			if(commands[sel].argc != argc) {
				com_puts("Command ");
				com_puts(cmd);
				com_puts(" takes ");
				com_puts(itoa(commands[sel].argc, buffer, 10));
				com_puts(" arguments!\n\r");
			} else {
				commands[sel].execute(arguments);
			}
			break;
		}
		if(commands[sel].pattern == NULL) {
			com_puts("Command ");
			com_puts(cmd);
			com_puts(" does not exist!\n\r");
		}
		CLEARLINE(linebuf);
	}
}

void dbg_quit()
{
	quit = true;
}

static void cmd_run(int * args) {
	(void)args;
	dbg_quit(); 
}

static void cmd_step(int * args) {
	(void)args;
	emu_step();
	cmd_info(NULL);
}

static void cmd_load(int * args) {
	(void)args;
	ihex_load();
}

static void cmd_read8(int * args) {
	int val = mem_read(args[0]);
	com_putc('$');
	com_puts(itoa(val, buffer, 16));
	com_puts("\n\r");
}

static void cmd_read16(int * args) {
	int val = mem_read16(args[0]);
	com_putc('$');
	com_puts(itoa(val, buffer, 16));
	com_puts("\n\r");
}

static void cmd_write8(int * args) {
	mem_write(args[0], args[1]);
}

static void cmd_write16(int * args) {
	mem_write16(args[0], args[1]);
}

static void cmd_breakpoint(int * args) {
	com_puts("Breakpoint ");
	uint16_t bp = args[0] & 0xFFFE;
	for(int i = 0; i < 8; i++) {
		if(breakpoints[i] == bp) {
			breakpoints[i] = 0xFFFF;
			com_puts(itoa(i, buffer, 10));
			com_puts(" disabled!\n\r");
			return;
		}
	}
	for(int i = 0; i < 8; i++) {
		if(breakpoints[i] == 0xFFFF) {
			breakpoints[i] = bp;
			com_puts(itoa(i, buffer, 10));
			com_puts(" enabled!\n\r");
			return;
		}
	}
	com_puts(" store full!\n\r");
}

static void cmd_jump(int * args) {
	regCP = args[0] & 0xFFFE;
}

static void cmd_push(int * args) {
	if(regSP >= STACKSIZE) {
		com_puts("Stack full!\n\r");
	} else {
		emu_push(args[0]);
	}
}
static void cmd_pop(int * args) {
	(void)args;
	if(regSP == 0) {
		com_puts("Stack empty!\n\r");
	} else {
		int val = emu_pop();
		com_puts(itoa(val, buffer, 10));
		com_puts("\n\r");
	}
}

static void cmd_reset(int * args) {
	(void)args;
	emu_init();
	cmd_info(NULL);
}

static void cmd_help(int * args) {
	(void)args;
	for(int i = 0; commands[i].pattern; i++)
	{
		com_puts(commands[i].pattern);
		com_putc('\t');
		com_puts(commands[i].description);
		com_puts("\r\n");
	}
}


#ifndef __AVR_GCC__

static void cmd_quit(int * args) {
	(void)args;
	exit(EXIT_SUCCESS);
}

#endif