#include "commandline.h"
#include "com.h"
#include "spi.h"

CONSOLECOMMAND(spiMaster, 0, "Initializes SPI in master mode")
{
	spi_initMaster();
	
	DDRB  |= 0x1F;
	PORTB |= 0x1F;
}

CONSOLECOMMAND(spiSlave, 0, "Initializes SPI in master mode")
{
	spi_initSlave();
}

CONSOLECOMMAND(xmit, 1, "Sends an byte signal")
{
	com_puts("xmit(out): $");
	com_putn(args[0], 16);
	
	int result = spi_xmit(args[0]);
	
	com_puts("\n\rxmot(in):  $");
	com_putn(result, 16);
	com_puts("\n\r");
}

CONSOLECOMMAND(cs, 1, "Selects an SPI slave")
{
	uint8_t index = 0;
	if(args[0] > 0) {
		index = (1<<(args[0] - 1));
	}
	PORTB = (PORTB & 0xE0) | ~index;
}