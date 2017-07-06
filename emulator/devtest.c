#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdbool.h>
#include <stdlib.h>
#include "com.h"
#include "sram.h"
#include <vt100.h>

int main()
{
	mem_init();
	com_init();
	sei();
	com_puts(VT_CLS VT_HOME "Device Test ready!\n\r");
	while(true)
	{
		commandline_open("(cmd) ");
	}
	return 0;
}