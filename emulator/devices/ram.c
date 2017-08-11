#include "../busdevice.h"

#include <stdlib.h>

static void init(busdevice_t * dev)
{
	dev->userData = malloc(1<<16);
}

static uint8_t read(busdevice_t * dev, uint16_t addr)
{
	uint8_t * memory = dev->userData;
	return memory[addr];
}

static void write(busdevice_t * dev, uint16_t addr, uint8_t value)
{
	uint8_t * memory = dev->userData;
	memory[addr] = value;
}

BUSDEVICE(1, "RAM", init, read, write)