#include "io.h"
#include "usart.h"

#include <stdio.h>

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
