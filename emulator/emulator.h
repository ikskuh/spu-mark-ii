#pragma once

#include <stdint.h>

#define STACKSIZE 512

typedef uint16_t word_t;
typedef uint8_t byte_t;

extern word_t regSP, regBP, regCP, regINTR;

extern word_t stack[];

void emu_init();

void emu_step();

/*
void emu_push(word_t value);
uint16_t emu_pop();
uint16_t emu_peek();
*/

static inline void emu_push(word_t value)
{
	stack[regSP++] = value;
}

static inline uint16_t emu_pop()
{
	return stack[--regSP];
}

static inline uint16_t emu_peek()
{
	return stack[regSP - 1];
}