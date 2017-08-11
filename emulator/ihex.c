#include "ihex.h"
#include "com.h"
#include "bus.h"

#include <string.h>

#define XON                     17       /* XON Zeichen */
#define XOFF                    19       /* XOFF Zeichen */
#define START_SIGN              ':'      /* Hex-Datei Zeilenstartzeichen */

#define PARSER_STATE_START      0
#define PARSER_STATE_SIZE       1
#define PARSER_STATE_ADDRESS    2
#define PARSER_STATE_TYPE       3
#define PARSER_STATE_DATA       4
#define PARSER_STATE_CHECKSUM   5
#define PARSER_STATE_ERROR      6

static uint16_t hex2num(const uint8_t * ascii, uint8_t num)
{
	uint16_t val = 0;
	for (uint8_t i = 0; i < num; i++)
	{
			uint8_t c = ascii[i];
			if (c >= '0' && c <= '9')      c -= '0';  
			else if (c >= 'A' && c <= 'F') c -= 'A' - 10;
			else if (c >= 'a' && c <= 'f') c -= 'a' - 10;
			val = 16 * val + c;
	}
	return val;
}

static uint8_t readbyte()
{
	uint8_t data[2];
	data[0] = com_getc();
	data[1] = com_getc();
	return hex2num(data, 2);
}

static uint16_t readword()
{
	uint8_t data[4];
	data[0] = com_getc();
	data[1] = com_getc();
	data[2] = com_getc();
	data[3] = com_getc();
	return hex2num(data, 4);
}

void ihex_load()
{
	com_puts("ihex loader rdy\n\r");

	while(true)
	{
		char start;
		do {
			start = com_getc();
			if(start == 'Q') {
				com_puts("ihex loader exit.\n\r");
				return;
			}
			if(start != ':' && start != '\n' && start != '\r') {
				com_puts("Invalid hex start!\n\r");
			}
		} while(start != ':');
		
		uint8_t len = readbyte();
		uint16_t offset = readword();
		uint8_t type = readbyte();
		
		uint8_t checksum = len + type + (offset & 0xFF) + (offset>>8);
		if(type == 0x00) {
			// data segment
			for(int i = 0; i < len; i++) {
				uint8_t data = readbyte();
				bus_write(offset++, data);
				checksum += data;
			}
		}
		// this is the checksum byte!
		checksum += readbyte();
		
		if(checksum != 0) {
			com_puts("Invalid checksum!\n\r");
		}
		
		if(type == 0x01) {
			// end
			break;
		}
		
		com_putc('.');
	}
	
	com_puts("\n\rihex loader done!\n\r");
}