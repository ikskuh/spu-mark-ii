#pragma once

#include <spu-2.h>
#include <stdint.h>

void mmu_init();

void mmu_write8(word_t address, byte_t value);

byte_t mmu_read8(word_t address);

void mmu_map(uint8_t bank, word_t address);

void mmu_swapContext(uint8_t context);

static inline void mmu_write16(word_t address, word_t value)
{
	mmu_write8(address + 0, value & 0xFF);
	mmu_write8(address + 1, value >> 8);
}

static inline word_t mmu_read16(word_t address)
{
	return
		mmu_read8(address + 0) |
		mmu_read8(address + 1) << 8;
}