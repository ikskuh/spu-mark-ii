#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <unistd.h>
#include <termios.h>
#include <unistd.h>
#include <getopt.h>

#include "io.h"
#include "com.h"
#include "sram.h"
#include "ihex.h"

// this prototype uses the define
int main();

#undef main

FILE * comin, * comout;
uint8_t * memory = NULL;

extern volatile bool emuBreakToDebugger;

// this is the actual main function
int main(int argc, char ** argv)
{
	// Allocate full memory :)
	memory = malloc(1<<16);
	comout = stdout;
	
	int opt;
	while((opt = getopt(argc, argv, "dl:")) != -1)
	{
		switch(opt)
		{
		case 'd':
			emuBreakToDebugger = true;
			break;
		case 'l': {
			FILE * f = fopen(optarg, "r");
			if(f == NULL) {
				fprintf(stderr, "File %s not found\n", optarg);
				exit(EXIT_FAILURE);
			}
			comin = f;
			ihex_load();
			comin = NULL;
			fclose(f);
			break;
		}
		default:
			fprintf(stderr, "Usage: %s [-r hexfile]\n", argv[0]);
			exit(EXIT_FAILURE);
		}
	}
	comin = stdin;
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


void mem_init()
{
	// We are already doing this in the main above
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
	return fgetc(comin);
}

void com_putc( unsigned char data )
{
	fputc(data, comout);
	fflush(comout);
}

bool com_canRead(void)
{
	return true;
}

bool com_canWrite(void)
{
	return true;
}