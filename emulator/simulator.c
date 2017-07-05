#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <unistd.h>
#include <termios.h>

#include "io.h"
#include "com.h"
#include "sram.h"

int _argc;
char ** _argv;

// this prototype uses the define
int main();

#undef main

// this is the actual main function
int main(int argc, char ** argv)
{
	_argc = argc;
	_argv = argv;

	return sim_main();
}

///////////////////////////////////////////////////////////////////////////////
// io.c
///////////////////////////////////////////////////////////////////////////////

void io_init()
{
	com_init();
}

void io_out(uint16_t port, uint8_t value)
{
	switch(port)
	{
		case 0: com_putc(value); break;
	}
}

uint8_t io_in(uint16_t port)
{
	switch(port)
	{
		case 0: return com_getc();
		default: return -1;
	}
}

///////////////////////////////////////////////////////////////////////////////
// memory.c
///////////////////////////////////////////////////////////////////////////////
uint8_t * memory = NULL;

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

///////////////////////////////////////////////////////////////////////////////
// com.c
///////////////////////////////////////////////////////////////////////////////


static struct termios com_termios;

static void com_shutdown()
{
	tcsetattr( STDIN_FILENO, TCSANOW, &com_termios);
}

void com_init()
{
	tcgetattr( STDIN_FILENO, &com_termios);
	
	static struct termios newt;
	newt = com_termios;
	newt.c_iflag &= ~(INLCR | ICRNL);
	newt.c_oflag &= ~(OCRNL | ONLCR);
	newt.c_lflag &= ~(ICANON | ECHO);
	tcsetattr( STDIN_FILENO, TCSANOW, &newt);

	atexit(com_shutdown);
}

unsigned char com_getc( void )
{
	return fgetc(stdin);
}

void com_putc( unsigned char data )
{
	fputc(data, stdout);
	fflush(stdout);
}

bool com_canRead(void)
{
	return true;
}

bool com_canWrite(void)
{
	return true;
}