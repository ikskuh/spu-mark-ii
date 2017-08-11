#include "mmu.h"
#include "bus.h"
#include "cpu.h"

struct context
{
	word_t banks[16];
	byte_t bflags[16];
	word_t sp, bp, ip;
	word_t cflags;
};

struct context contexts[256];

static uint8_t currentContext = 0;

#define CCONTEXT (contexts[currentContext])

void mmu_init()
{
	currentContext = 0;
	for(int i = 0; i < 16; i++) {
		CCONTEXT.banks[i] = 0;
	}
}

void mmu_map(uint8_t bank, word_t address)
{
	CCONTEXT.banks[bank & 0xF] = address;
}

void mmu_swapContext(uint8_t context)
{
	CCONTEXT.sp = regSP;
	CCONTEXT.bp = regBP;
	CCONTEXT.ip = regIP;
	currentContext = context;
	regSP = CCONTEXT.sp;
	regBP = CCONTEXT.bp;
	regIP = CCONTEXT.ip;
}

void mmu_write8(uint16_t address, uint8_t value)
{
	busaddr_t busaddr =
		(CCONTEXT.banks[address >> 12] << 8)
		+ (address & 0x0FFF);
	bus_write(busaddr, value);
}

uint8_t mmu_read8(uint16_t address)
{
	busaddr_t busaddr =
		(CCONTEXT.banks[address >> 12] << 8)
		+ (address & 0x0FFF);
	return bus_read(busaddr);
}