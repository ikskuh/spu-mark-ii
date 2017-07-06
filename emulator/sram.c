#include "sram.h"
#include <avr/io.h>
#include <util/delay.h>

/*

PORTA   = Adressleitung
PORTC   = Datenleitungen

PORTD.0 = Debug-Schnittstelle
PORTD.1 = Debug-Schnittstelle
PORTD.4 = Flip-Flop-Clock
PORTD.5 = SRAM-Write-Enable
PORTD.6 = SRAM-Output-Enable

*/

#define SRAM_FF (1<<PD4)
#define SRAM_WE (1<<PD5)
#define SRAM_OE (1<<PD6)

void mem_init()
{
	DDRA  = 0xFF;
	DDRD  |= SRAM_FF | SRAM_WE | SRAM_OE;
	PORTD |= SRAM_FF | SRAM_WE | SRAM_OE;
}

#define mem_sleep() _delay_us(0.8)

static inline void mem_setaddr(uint16_t addr)
{
	// Setup the flip-flops first
	PORTA = (addr >> 0) & 0xFF;
	PORTD &= ~SRAM_FF;
	PORTD |=  SRAM_FF;
	
	PORTA = (addr >> 8) & 0xFF;
}

void mem_write(uint16_t addr, uint8_t value)
{
	mem_setaddr(addr);
	
	PORTC = value;
	DDRC  = 0xFF;
	PORTD &= ~SRAM_WE;
	mem_sleep();
	PORTD |=  SRAM_WE;
	DDRC  = 0x00;
	PORTC = 0x00;
}

uint8_t mem_read(uint16_t addr)
{
	mem_setaddr(addr);
	
	DDRC = 0x00;
	PORTD &= ~SRAM_OE;
	mem_sleep();
	uint8_t data = PINC;
	PORTD |=  SRAM_OE;
	return data;
}