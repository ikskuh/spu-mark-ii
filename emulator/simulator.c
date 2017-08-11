#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <unistd.h>
#include <termios.h>
#include <unistd.h>
#include <getopt.h>
#include <signal.h>

#include "com.h"
#include "ihex.h"
#include "platform.h"

// this prototype uses the define
int main();

#undef main

FILE * comin, * comout;

extern volatile bool emuBreakToDebugger;

static void sigDebug(int sigNum)
{
	(void)sigNum;
	emuBreakToDebugger = true;
	
	signal(SIGINT, sigDebug);
}

// this is the actual main function
void platform_init(PLATFORM_MAIN)
{
	signal(SIGINT, sigDebug);
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
			fprintf(stderr, "Usage: %s [-d] [-l hexfile]\n", argv[0]);
			exit(EXIT_FAILURE);
		}
	}
	comin = stdin;
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
	//tcsetattr( STDIN_FILENO, TCSANOW, &newt);

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