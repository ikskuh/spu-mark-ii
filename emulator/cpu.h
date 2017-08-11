#pragma once

#include <stdint.h>

#include <spu-2.h>

extern word_t regSP, regBP, regIP, regINTR;

void cpu_init();

void cpu_step();

void cpu_push(word_t value);
word_t cpu_pop();
word_t cpu_peek();
