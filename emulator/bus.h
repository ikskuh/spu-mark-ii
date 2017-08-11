#pragma once

#include <spu-2.h>

typedef uint32_t busaddr_t;

void bus_init();

void bus_write(busaddr_t addr, byte_t value);

byte_t bus_read(busaddr_t addr);