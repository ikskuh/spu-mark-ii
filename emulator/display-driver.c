#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdlib.h>

#include "com.h"
#include "spi.h"
#include <vt100.h>

#define LCD_EN (1<<PB0)
#define LCD_RE (1<<PB1)
#define LCD_RS (1<<PB2)

#define LCD_MASK (LCD_RE | LCD_RS | LCD_EN)

#define LCD_DATA LCD_RS
#define LCD_CMD  0

#define lcd_delay() _delay_us(25.0)

static void lcd_write(uint8_t reg, uint8_t data);
static uint8_t lcd_read(uint8_t reg);

void lcd_cmd(uint8_t cmd);
void lcd_data(uint8_t value);

static void lcd_wait()
{
	while(lcd_read(0) & 0x80) {
		com_putc('.');
		_delay_ms(100);
	}
}

static uint8_t lcd_read(uint8_t cfg)
{
	uint8_t data = 0xFF;
	PORTB = (PORTB & ~LCD_MASK) | (cfg & LCD_MASK) | LCD_RE;
	DDRD  = 0x00;
	PORTA = 0x00;
	lcd_delay();
	PORTB |= LCD_EN;
	lcd_delay();
	data = PINA;
	lcd_delay();
	PORTB &= ~LCD_EN;
	lcd_delay();
	PORTB &= ~LCD_MASK;
	return data;
}

static void lcd_write(uint8_t reg, uint8_t data)
{
	lcd_wait();
	
	PORTB = (PORTB & ~LCD_MASK) | (reg & LCD_MASK);
	DDRA  = 0xFF;
	PORTA = data;
	lcd_delay();
	PORTB |= LCD_EN;
	lcd_delay();
	PORTB &= ~LCD_EN;
	lcd_delay();
	PORTB &= ~LCD_MASK;
	lcd_delay();
	DDRA = 0x00; // Output off
	PORTA = 0x00; // PULLUP off
}

void lcd_cmd(uint8_t cmd)
{
	lcd_wait();
	lcd_write(LCD_CMD, cmd);
}

void lcd_data(uint8_t cmd)
{
	lcd_wait();
	lcd_write(LCD_DATA, cmd);
}

void lcd_puts(char const * str)
{
	while(*str) lcd_data(*str++);
}

void lcd_cls()
{
	lcd_cmd(0x01);
}

void lcd_sda(uint8_t addr)
{
	lcd_cmd(0x80 | (addr & 0x7F));
}

void lcd_sca(uint8_t addr)
{
	lcd_cmd(0x40 | (addr & 0x3F));
}

void lcd_setcur(uint8_t x, uint8_t y)
{
	uint8_t addresses[] = { 0x00, 0x40, 0x14, 0x54 };
	lcd_sda(addresses[y] + x);
}

int main()
{
	com_init();
	
	com_puts(VT_CLS VT_HOME "Hello, Display!\n\r");
	
	DDRB  |= LCD_MASK;
	PORTB |= LCD_MASK;
	
	lcd_cmd(0x38);
	lcd_cmd(0x08 + 0x04);
	lcd_cmd(0x06);
	
	lcd_cls();
	lcd_setcur(0, 0); lcd_puts("Output:");
	lcd_setcur(0, 1); lcd_puts("Input:");
	
	spi_initSlave();
	
	DDRD |= (1<<PD7);
	
	uint8_t i = 0;
	while(true)
	{
		int val = spi_xmit(i);
		PORTD ^= (1<<PD7);
		char buf[8];
		lcd_setcur(8, 0); lcd_puts(itoa(i  , buf, 10));
		lcd_setcur(8, 1); lcd_puts(itoa(val, buf, 16));
		
		i += 1;
	}
}