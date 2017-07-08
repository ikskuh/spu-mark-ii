#include "spi.h"

#define DDR_SPI DDRB
#define DDR_MOSI PB5
#define DDR_MISO PB6

void spi_initMaster(void)
{
	/* Set MOSI and SCK output, all others input */
	DDR_SPI = (DDR_SPI & ~DD_MASK) | (DD_MASK & ((1<<DD_MOSI)|(1<<DD_SCK)));
	/* Enable SPI, Master, set clock rate fck/16 */
	SPCR = (1<<SPE)|(1<<MSTR)|(1<<SPR0)|(1<<SPR1);
}

void spi_initSlave(void)
{
	/* Set MISO output, all others input */
	DDR_SPI = (DDR_SPI & ~DD_MASK) | (DD_MASK & ((1<<DD_MISO)));
	/* Enable SPI */
	SPCR = (1<<SPE);
}

uint8_t spi_xmit(uint8_t data)
{
	SPDR = data;
	while(!(SPSR & (1<<SPIF)));
	return SPDR;
}

void spi_send(uint8_t data)
{
	SPDR = data;
	while(!(SPSR & (1<<SPIF)));
}

uint8_t spi_receive()
{
	while(!(SPSR & (1<<SPIF)));
	return SPDR;
}
