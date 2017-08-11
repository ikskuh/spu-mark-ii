#include "cpu.h"
#include "mmu.h"
#include "com.h"
#include "spu-2.h"

#include <stdbool.h>
#include <stdio.h>

word_t regSP, regBP, regIP, regINTR;

struct {
	unsigned int z : 1;
	unsigned int n : 1;
	unsigned int i : 1;
} regFLAG;

static word_t input0, input1, output;

void cpu_init()
{
	regSP   = 0;
	regBP   = 0;
	regIP   = 0;
	regINTR = 0;
	regFLAG.z = 0;
	regFLAG.n = 0;
	regFLAG.i = 0;
}

// GetNextInstructionWord
static inline word_t cpu_gniw()
{
	word_t iword = mmu_read16(regIP & 0xFFFE);
	regIP += 2;
	return iword;
}

void cpu_step()
{
	if(regFLAG.i && regINTR > 0)
	{
		cpu_push(regIP);
		regIP   = (regINTR << 2);
		regINTR = 0;
	}

	word_t iword = cpu_gniw();
	struct {
		uint8_t exec   ;
		uint8_t flags  ;
		uint8_t input0 ;
		uint8_t input1 ;
		uint8_t output ;
		uint8_t command;
	} i = {
		INSTR_GETEXEC(iword),
		INSTR_GETFLAG(iword),
		INSTR_GETI0(iword),
		INSTR_GETI1(iword),
		INSTR_GETOUT(iword),
		INSTR_GETCMD(iword),
	};
	
	bool exec = false;
	switch(i.exec)
	{
		case EXEC_ALWAYS:  exec =  true;                    break;
		case EXEC_ZERO:    exec =  regFLAG.z;               break;
		case EXEC_NONZERO: exec = !regFLAG.z;               break;
		case EXEC_GREATER: exec = !regFLAG.z && !regFLAG.n; break;
		case EXEC_LESS:    exec =  regFLAG.n;               break;
		case EXEC_GEQUAL:  exec =  regFLAG.z || !regFLAG.n; break;
		case EXEC_LEQUAL:  exec =  regFLAG.z ||  regFLAG.n; break;
		case EXEC_NEVER:   exec =  false;                   break;
	}

	if(!exec) {
		// We still need to advance
		if(i.input0 == INPUT_ARG) cpu_gniw();
		if(i.input1 == INPUT_ARG) cpu_gniw();
		return;
	}
	
	switch(i.input0) {
		case INPUT_ZERO: input0 = 0; break;
		case INPUT_ARG:  input0 = cpu_gniw(); break;
		case INPUT_PEEK: input0 = cpu_peek(); break;
		case INPUT_POP:  input0 = cpu_pop(); break;
	}
	
	switch(i.input1) {
		case INPUT_ZERO: input1 = 0; break;
		case INPUT_ARG:  input1 = cpu_gniw(); break;
		case INPUT_PEEK: input1 = cpu_peek(); break;
		case INPUT_POP:  input1 = cpu_pop(); break;
	}
	
	switch(i.command)
	{
		case CMD_COPY:
			output = input0;
			break;
		case CMD_CPGET:
			output = regIP + input0;
			break;
		case CMD_GET:
			output = mmu_read16(regSP + regBP + ((input0 - 2)<<1));
			break;
		case CMD_SET:
			output = input1;
			mmu_write16(regSP + regBP + ((input0 - 2)<<1), input1);
			break;
		case CMD_STOR8:
			output = input1;
			mmu_write8(input0, output);
			break;
		case CMD_STOR16:
			output = input1;
			mmu_write16(input0, output);
			break;
		case CMD_LOAD8:
			output = mmu_read8(input0);
			break;
		case CMD_LOAD16:
			output = mmu_read16(input0);
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
		case CMD_ASR:
			output = (input0 >> 1) | (input0 & 0x8000);
			break;
		case CMD_LSL:
			output = (input0 << 1);
			break;
		case CMD_LSR:
			output = (input0 >> 1);
			break;
		case CMD_MAPMMU:
			mmu_map(input0, input1);
			output = input1;
			break;
		case CMD_BSWAP:
			output = (input0 << 8) | (input0 >> 8);
			break;
		default:
			fprintf(stderr, "Unsupported command: $%X\n", i.command);
			abort();
	}
	
	if(i.flags) {
		regFLAG.z = (output == 0);
		regFLAG.n = ((output & 0x8000) != 0);
	}
	
	switch(i.output) {
		case OUTPUT_DISCARD: break;
		case OUTPUT_PUSH: cpu_push(output); break;
		case OUTPUT_JUMP: regIP = output & 0xFFFE; break;
		case OUTPUT_RJUMP: regIP = (regIP + output) & 0xFFFE; break;
	}
}

void cpu_push(word_t value)
{
	mmu_write16(regSP, value);
	regSP += 2;
}

word_t cpu_pop()
{
	regSP -= 2;
	return mmu_read16(regSP);
}

word_t cpu_peek()
{
	return mmu_read16(regSP - 2);
}