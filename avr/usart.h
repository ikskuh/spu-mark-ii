#pragma once

#include <stdbool.h>
#include <stddef.h>

// #define UART_ASYNC
#define BAUD 9600UL

void com_init(void);

unsigned char com_getc( void );
void com_putc( unsigned char data );
bool com_canRead(void);
bool com_canWrite(void);

static inline void com_write(void const * data, size_t len)
{
	unsigned char const * buffer = data;
	while(len > 0) {
		while(!com_canWrite());
		com_putc(*buffer++);
		len--;
	}
}

static inline void com_puts(char const * str)
{
	while(*str) {
		while(!com_canWrite());
		com_putc(*str++);
	}
}

static inline void com_read(void * data, size_t len)
{
	unsigned char * buffer = data;
	while(len > 0) {
		*buffer++ = com_getc();
		len--;
	}
}