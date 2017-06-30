#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdbool.h>
#include <stdlib.h>
#include "usart.h"
#include "sram.h"
#include "io.h"
#include "emulator.h"
#include "spu-2.h"

#define INSTR(ez, en, i0, i1, fl, ou, cm) 0 \
	| ((ez & 03) << 0) \
	| ((en & 03) << 2) \
	| ((i0 & 03) << 4) \
	| ((i1 & 03) << 6) \
	| ((fl & 01) << 8) \
	| ((ou & 03) << 9) \
	| ((cm & 31) << 11)

uint16_t code[] = 
{
	// push '\r'
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'\r',
	
	// push '\n'
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'\n',
	
	// push '\!'
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'!',
	
	// push '\o'
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'o',
	
	// push '\l'
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'l',
	
	// dup
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_PEEK, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	
	// push 'e'
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'e',
	
	// push 'H'
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'H',
	
	// 8 * out 0
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	
	// in 0
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ZERO, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_INPUT),
	// out 0
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	
	// jmp *-8
	INSTR(EXEC_ALWAYS, EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_RJUMP, CMD_COPY),
	-8
};

int main()
{
	com_init();
	mem_init();
	emu_init();
	io_init();
	
	// Initialize memory :)
	for(unsigned i = 0; i < (sizeof(code) / sizeof(code[0])); i++) {
		mem_write16(2*i, code[i]);
	}
	
	while(true)
	{
		emu_step();
	}
	
	return 0;
}