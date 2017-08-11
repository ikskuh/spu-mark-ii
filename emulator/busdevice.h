#pragma once

#include <stdint.h>

typedef struct busdevice
{
	uint8_t slot;
	char const * name;
	void (*init)(struct busdevice * dev);
	uint8_t (*read)(struct busdevice * dev, uint16_t addr);
	void (*write)(struct busdevice * dev, uint16_t addr, uint8_t value);
	void * userData;
} busdevice_t;

void busdevice_register(busdevice_t * device);

#define BUSDEVICE(SLOT, NAME, INIT, READ, WRITE) \
	static busdevice_t _busdev_##SLOT = { \
		SLOT, NAME, INIT, READ, WRITE, NULL \
	}; \
	static void __attribute__((constructor)) _busdev_##SLOT##_init() { \
		busdevice_register(&_busdev_##SLOT); \
	}
