#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdbool.h>
#include <stdlib.h>
#include "usart.h"
#include "sram.h"

void delay_ms(uint16_t ms)
{
	while(ms > 0) {
		_delay_ms(1);
		ms -= 1;
	}
}

int main()
{
	com_init();
	mem_init();
	
	sei();
	
	static char buffer[16];
	static int errcount = 0;
	while(true)
	{
		for(int page = 0; page < 256; page++) {
			// HOME,CLS
			com_puts("\033[H\033[2JBase Address: 0x");
			com_puts(itoa(page, buffer, 16));
			com_puts("00\r\nErrors:       ");
			com_puts(itoa(errcount, buffer, 10));
			com_puts("\n\r");
			
			for(int i = 0; i < 256; i++) {
				uint16_t addr = (page << 8) + i;
				uint8_t val = ~addr;
				
				mem_write(addr, val);
				
				mem_write(addr - 1, addr + 1);
				mem_write(addr + 1, addr - 1);
				
				uint8_t dat = mem_read(addr);
				
				if(dat != val) {
					com_putc('X');
					errcount++;
				} else {
					com_putc(' ');
				}
				if((i % 16) == 15) {
					com_puts("\n\r");
				}
			}
			delay_ms(50);
		}
	}
	return 0;
}