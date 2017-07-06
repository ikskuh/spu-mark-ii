#include "platform.h"

#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>

extern volatile bool emuBreakToDebugger;

ISR(INT0_vect)
{
	emuBreakToDebugger = true;
}

void platform_init()
{
	MCUCR |= (1<<ISC00) | (1<<ISC01);
	GICR  |= (1<<INT0);
	sei();
}