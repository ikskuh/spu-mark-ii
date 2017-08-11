#include "../busdevice.h"
#include "../com.h"

static void init(busdevice_t * dev)
{
	
}

static uint8_t read(busdevice_t * dev, uint16_t addr)
{
	return com_getc();
}

static void write(busdevice_t * dev, uint16_t addr, uint8_t value)
{
	com_putc(value);
}

BUSDEVICE(128, "Serial", init, read, write)