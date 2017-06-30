#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <termios.h>

/*
#include "usart.h"
#include "sram.h"
#include "io.h"
#include "emulator.h"
#include "spu-2.h"

#define INSTR(ex, i0, i1, fl, ou, cm) 0 \
	| ((ex & 05) << 0) \
	| ((fl & 01) << 3) \
	| ((i0 & 03) << 4) \
	| ((i1 & 03) << 6) \
	| ((ou & 03) << 8) \
	| ((cm & 63) << 10)

uint16_t code[] = 
{
	// push '\r'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'\r',
	
	// push '\n'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'\n',
	
	// push '\!'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'!',
	
	// push '\o'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'o',
	
	// push '\l'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'l',
	
	// dup
	INSTR(EXEC_ALWAYS, INPUT_PEEK, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	
	// push 'e'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'e',
	
	// push 'H'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'H',
	
	// 8 * out 0
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	
	// in 0
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_INPUT),
	// out 0
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	
	// jmp *-8
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_RJUMP, CMD_COPY),
	-8
};

///////////////////////////////////////////////////////////////////////////////
// simulator.c
///////////////////////////////////////////////////////////////////////////////

int main(int argc, char ** argv)
{
	(void)argc;
	(void)argv;

	mem_init();
	emu_init();
	io_init();
	
	// Initialize memory :)
	const unsigned count = (sizeof(code) / sizeof(code[0]));
	for(unsigned i = 0; i < count; i++) {
		mem_write16(2*i, code[i]);
	}
	
	printf("Startup!\n\r");
	
	while(true)
	{
		emu_step();
	}
	
	return 0;
}
*/

///////////////////////////////////////////////////////////////////////////////
// io.c
///////////////////////////////////////////////////////////////////////////////

static struct termios io_termios;

static void io_shutdown()
{
	tcsetattr( STDIN_FILENO, TCSANOW, &io_termios);
}

void io_init()
{
	tcgetattr( STDIN_FILENO, &io_termios);
	
	static struct termios newt;
	newt = io_termios;
	newt.c_lflag &= ~(ICANON | ECHO);          
	tcsetattr( STDIN_FILENO, TCSANOW, &newt);

	atexit(io_shutdown);
}

void io_out(uint16_t port, uint8_t value)
{
	switch(port)
	{
		case 0: fputc(value, stdout); break;
	}
}

uint8_t io_in(uint16_t port)
{
	switch(port)
	{
		case 0: return fgetc(stdin);
		default: return -1;
	}
}

///////////////////////////////////////////////////////////////////////////////
// memory.c
///////////////////////////////////////////////////////////////////////////////
static uint8_t * memory = NULL;

void mem_init()
{
	// Allocate full memory :)
	memory = malloc(1<<16);
}

uint8_t mem_read(uint16_t address)
{
	return memory[address];
}

void mem_write(uint16_t address, uint8_t value)
{
	memory[address] = value;
}
