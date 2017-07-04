#pragma once
#include <stdint.h>
#include <stdbool.h>
#include "emulator.h"

#ifdef TRACE

void trace_init();

void trace_stack(word_t * stack, int bp, int count);

void trace_instr(uint16_t addr, uint16_t instr, uint16_t top, int flags, bool exec);

void trace_result(uint16_t result);

void trace_intr(uint16_t intr);

#else

#define trace_init()
#define trace_stack(stack, bp, count)
#define trace_instr(addr, instr, top, flags, exec)
#define trace_result(result)
#define trace_intr(intr)

#endif