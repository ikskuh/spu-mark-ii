#include <avr/io.h>
#include <util/delay.h>



// PORTC = DATA
// PB0 = EN
// PB1 = RW
// PB2 = RS

#define EN (1<<0)
#define RW (1<<1)
#define RS (1<<2)

#define MASK (EN|RW|RS)

uint8_t display_read(uint8_t cfg)
{
	uint8_t data = 0xFF;
	PORTB = (PORTB & ~MASK) | (cfg & MASK) | RW;
	DDRD  = 0x00;
	PORTD = 0x00;
	_delay_us(10);
	PORTB |= EN;
	_delay_us(10);
	data = PIND;
	_delay_us(10);
	PORTB &= ~EN;
	_delay_us(10);
	PORTB &= ~MASK;
	return data;
}

void display_wait()
{
	PORTB |= 0x20;
	while(display_read(0) & 0x80) {
		_delay_us(5);
	}
	PORTB &= ~0x20;
}

void display_write(uint8_t cfg, uint8_t data)
{
	display_wait();
	
	PORTB = (PORTB & ~MASK) | (cfg & MASK);
	DDRD  = 0xFF;
	PORTD = data;
	_delay_us(10);
	PORTB |= EN;
	_delay_us(10);
	PORTB &= ~EN;
	_delay_us(10);
	PORTB &= ~MASK;
	_delay_us(20);
	DDRD = 0x00; // Output off
	PORTD = 0x00; // PULLUP off
}

void cls()
{
	display_write(0, 0x01);
}

void setDisplayAddr(uint8_t addr)
{
	display_write(0, 0x80 | (addr & 0x7F));
}

void setCharAddr(uint8_t addr)
{
	display_write(0, 0x40 | (addr & 0x3F));
}

uint8_t fancy[] = 
{
	037,
	021,
	021,
	021,
	021,
	021,
	021,
	037,
	
	037,
	021,
	025,
	025,
	025,
	025,
	021,
	037,
	
	037,
	020,
	010,
	004,
	010,
	020,
	037,
	000,
	
	037,
	033,
	025,
	021,
	025,
	025,
	037,
	000,
};

int main()
{
	DDRB = MASK; // EN,RW,RS = Output
	
	UCSR0B = 0;
	UCSR0C = 0;
	
	display_write(0, 0x38);
	display_write(0, 0x0F);
	display_write(0, 0x06);
	
	cls();
	
	setCharAddr(0x00);
	for(int i = 0; i < 32; i++) {
		display_write(RS, fancy[i]);
	}
	
	setDisplayAddr(0x00);
	display_write(RS, 0x00);
	
	setDisplayAddr(0x40);
	display_write(RS, 0x01);
	
	setDisplayAddr(0x14);
	display_write(RS, 0x02);
	
	setDisplayAddr(0x54);
	display_write(RS, 0x03);
	
	setDisplayAddr(0x54 + 10);
	while(1);
	
	return 0;
}