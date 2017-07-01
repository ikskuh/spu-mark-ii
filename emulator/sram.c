#include "sram.h"
#include <avr/io.h>
#include <util/delay.h>

// PORTA = Daten
// PORTB = Addresse (Low Byte)
// PORTC = Addresse (High Byte)
// PD2 = WriteE̅nable
// PD3 = OutputE̅nable

#define MEM_WE (1<<PD2)
#define MEM_OE (1<<PD3)

void mem_init()
{
	DDRA   = 0x00;
	DDRB   = 0xFF;
	DDRC   = 0xFF;
	DDRD  |= 0x0C;
	PORTD |= MEM_OE | MEM_WE;
}

static inline void mem_wait()
{
	_delay_us(0.6); // wait 1000ns
}

uint8_t mem_read(uint16_t address)
{
	PORTB = (address >> 0) & 0xFF;
	PORTC = (address >> 8) & 0xFF;
	
	DDRA  = 0x00;
	PORTD &= ~MEM_OE;
	mem_wait();
	uint8_t data = PINA;
	PORTD |= MEM_OE;
	DDRA = 0x00;
	return data;
}

void mem_write(uint16_t address, uint8_t value)
{
	PORTB = (address >> 0) & 0xFF;
	PORTC = (address >> 8) & 0xFF;
	
	DDRA  = 0xFF;
	PORTA = value;
	PORTD &= ~MEM_WE;
	mem_wait();
	PORTD |= MEM_WE;
	DDRA = 0x00;
}
