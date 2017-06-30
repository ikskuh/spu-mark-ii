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

#define INSTR(ex, i0, i1, fl, ou, cm) 0 \
	| ((ex & 05) << 0) \
	| ((fl & 01) << 3) \
	| ((i0 & 03) << 4) \
	| ((i1 & 03) << 6) \
	| ((ou & 03) << 8) \
	| ((cm & 63) << 10)

uint16_t code[] = 
{
	// push '\r'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'\r',
	
	// push '\n'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'\n',
	
	// push '\!'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'!',
	
	// push '\o'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'o',
	
	// push '\l'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'l',
	
	// dup
	INSTR(EXEC_ALWAYS, INPUT_PEEK, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	
	// push 'e'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'e',
	
	// push 'H'
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_COPY),
	'H',
	
	// 8 * out 0
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	
	// in 0
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_ZERO, 0, OUTPUT_PUSH, CMD_INPUT),
	// out 0
	INSTR(EXEC_ALWAYS, INPUT_ZERO, INPUT_POP, 0, OUTPUT_DISCARD, CMD_OUTPUT),
	
	// jmp *-8
	INSTR(EXEC_ALWAYS, INPUT_ARG, INPUT_ZERO, 0, OUTPUT_RJUMP, CMD_COPY),
	-8
};

int main()
{
	com_init();
	mem_init();
	emu_init();
	io_init();
	
	// Initialize memory :)
	const unsigned count = (sizeof(code) / sizeof(code[0]));
	for(unsigned i = 0; i < count; i++) {
		mem_write16(2*i, code[i]);
	}
	
	com_puts("Startup!\n\r");
	
	while(true)
	{
		emu_step();
	}
	
	return 0;
}