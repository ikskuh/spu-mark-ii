#include "emulator.h"
#include "sram.h"
#include "io.h"
#include "spu-2.h"

#include <stdbool.h>

#include <stdio.h>

word_t regSP, regBP, regCP, regFLAG, regINTR;

word_t stack[STACKSIZE];

static word_t input0, input1, output;

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

void emu_init()
{
	regSP = 0;
	regBP = 0;
	regCP = 0;
}

// GetNextInstructionWord
static uint16_t emu_gniw()
{
	word_t iword = mem_read16(regCP & 0xFFFE);
	regCP += 2;
	return iword;
}

void emu_step()
{
	word_t iword = emu_gniw();
	struct {
		unsigned int execZ  ; // 0
		unsigned int execN  ; // 2
		unsigned int input0 ; // 4
		unsigned int input1 ; // 6
		unsigned int flags  ; // 8
		unsigned int output ; // 9
		unsigned int command; // 11
	} i = {
		(iword >>  0) & 03,
		(iword >>  2) & 03,
		(iword >>  4) & 03,
		(iword >>  6) & 03,
		(iword >>  8) & 01,
		(iword >>  9) & 03,
		(iword >> 11) & 31,
	};
	
	bool exec = 
		   ((i.execZ & EXEC_ALWAYS) || ((i.execZ & EXEC_SET) == !!(regFLAG & FLAG_ZERO)))
		&& ((i.execN & EXEC_ALWAYS) || ((i.execN & EXEC_SET) == !!(regFLAG & FLAG_NEG)));
	if(!exec) {
		// We still need to advance
		if(i.input0 == INPUT_ARG) emu_gniw();
		if(i.input1 == INPUT_ARG) emu_gniw();
		return;
	}
	
	switch(i.input0) {
		case INPUT_ZERO: input0 = 0; break;
		case INPUT_ARG:  input0 = emu_gniw(); break;
		case INPUT_PEEK: input0 = emu_peek(); break;
		case INPUT_POP:  input0 = emu_pop(); break;
	}
	
	switch(i.input1) {
		case INPUT_ZERO: input1 = 0; break;
		case INPUT_ARG:  input1 = emu_gniw(); break;
		case INPUT_PEEK: input1 = emu_peek(); break;
		case INPUT_POP:  input1 = emu_pop(); break;
	}
	
	switch(i.command)
	{
		case CMD_COPY:
			output = input0;
			break;
		case CMD_CPGET:
			output = regCP + input0;
			break;
		case CMD_GET:
			output = stack[regBP + input0];
			break;
		case CMD_SET:
			output = stack[regBP + input0] = input1;
			break;
		case CMD_STOR8:
			output = input1;
			mem_write(input0, output);
			break;
		case CMD_STOR16:
			output = input1;
			mem_write16(input0, output);
			break;
		case CMD_SETINT:
			if(input0) {
				regFLAG |= FLAG_INTR;
			} else {
				regFLAG &= ~FLAG_INTR;
			}
			break;
		case CMD_INT:
			regINTR = (input0 << 1);
			break;
		case CMD_LOAD8:
			output = mem_read(input0);
			break;
		case CMD_LOAD16:
			output = mem_read16(input0);
			break;
		case CMD_INPUT:
			output = io_in(input0);
			break;
		case CMD_OUTPUT:
			output = input1;
			io_out(input0, input1);
			break;
		case CMD_BPGET:
			output = regBP;
			break;
		case CMD_BPSET:
			output = regBP = input0;
			break;
		case CMD_SPGET:
			output = regSP;
			break;
		case CMD_SPSET:
			output = regSP = input0;
			break;
		case CMD_ADD:
			output = input0 + input1;
			break;
		case CMD_SUB:
			output = input0 - input1;
			break;
		case CMD_MUL:
			output = input0 * input1;
			break;
		case CMD_DIV:
			output = input0 / input1;
			break;
		case CMD_MOD:
			output = input0 % input1;
			break;
		case CMD_AND:
			output = input0 & input1;
			break;
		case CMD_OR:
			output = input0 | input1;
			break;
		case CMD_XOR:
			output = input0 ^ input1;
			break;
		case CMD_NOT:
			output = ~input0;
			break;
		case CMD_NEG:
			output = -input0;
			break;
		case CMD_ROL:
			output = (input0 << 1) | (input0 >> 15);
			break;
		case CMD_ROR:
			output = (input0 << 15) | (input0 >> 1);
			break;
		case CMD_ASL:
			// HAU MICH!
			output = (input0 << 1);
			break;
		case CMD_ASR:
			output = (input0 >> 1) | (input0 & 0x8000);
			break;
		case CMD_LSL:
			output = (input0 << 1);
			break;
		case CMD_LSR:
			output = (input0 >> 1);
			break;
	}
	
	if(i.flags) {
		regFLAG &= ~(FLAG_ZERO | FLAG_NEG);
		if(output == 0)
			regFLAG |= FLAG_ZERO;
		if(output & 0x8000) {
			regFLAG |= FLAG_NEG;
		}
	}
	
	switch(i.output) {
		case OUTPUT_DISCARD: break;
		case OUTPUT_PUSH: emu_push(output); break;
		case OUTPUT_JUMP: regCP = output & 0xFFFE; break;
		case OUTPUT_RJUMP: regCP = (regCP + output) & 0xFFFE; break;
	}
	
	if(regSP >= STACKSIZE) {
		// CPU Reset on Stack Under/Overflow :(
		emu_init();
	}
}