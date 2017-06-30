#pragma once

#include <stdint.h>

void mem_init();

uint8_t mem_read(uint16_t address);

void mem_write(uint16_t address, uint8_t val);

static inline uint16_t mem_read16(uint16_t address)
{
	return
		(mem_read(address + 0) << 0) |
		(mem_read(address + 1) << 8);
}

static inline void mem_write16(uint16_t address, uint16_t value)
{
	mem_write(address + 0, (value >> 0) & 0xFF);
	mem_write(address + 1, (value >> 8) & 0xFF);
}