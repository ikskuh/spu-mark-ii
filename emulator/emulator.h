#pragma once

#include <stdint.h>

#define STACKSIZE 512

typedef uint16_t word_t;
typedef uint8_t byte_t;

void emu_init();

void emu_step();
