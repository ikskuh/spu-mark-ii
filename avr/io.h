#pragma once

#include <stdint.h>

void io_init();

void io_out(uint16_t port, uint8_t value);

uint8_t io_in(uint16_t port);