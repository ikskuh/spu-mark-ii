#include "../busdevice.h"

#include <stdlib.h>

extern const void bootrom_start;
extern const void bootrom_end;
extern const void bootrom_size;

static uint8_t read(busdevice_t * dev, uint16_t addr)
{
	(void)dev;
	uint8_t const * memory = &bootrom_start;
	if(addr >= (size_t)&bootrom_size)
		return 0xFF; // floating bus
	return memory[addr];
}

BUSDEVICE(0, "ROM", NULL, read, NULL)