#include "bus.h"
#include "busdevice.h"
#include <stdio.h>
#include <assert.h>

busdevice_t * devices[256];

void bus_init()
{
	for(int i = 0; i < 256; i++) {
		if(devices[i] == NULL)
			continue;
		if(devices[i]->init) devices[i]->init(devices[i]);
	}
}

void bus_write(busaddr_t addr, byte_t value)
{
	uint8_t  devID   = (addr >> 16) & 0xFF;
	uint16_t devAddr = addr & 0xFFFF;
	busdevice_t * dev = devices[devID];
	assert(dev);
	if(dev->write) dev->write(dev, devAddr, value);
}

byte_t bus_read(busaddr_t addr)
{
	uint8_t  devID   = (addr >> 16) & 0xFF;
	uint16_t devAddr = addr & 0xFFFF;
	busdevice_t * dev = devices[devID];
	assert(dev);
	if(dev->read) 
		return dev->read(dev, devAddr);
	else
		return 0xFF;
}

void busdevice_register(busdevice_t * dev)
{
	if(devices[dev->slot] != NULL) {
		fprintf(stderr, 
			"Device slot %d is used twice!\n",
			dev->slot);
		abort();
	}
	devices[dev->slot] = dev;
}