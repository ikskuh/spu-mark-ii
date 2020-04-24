#pragma once

#include <stdint.h>

#define SPU_VERSION_MAJOR 2
#define SPU_VERSION_MINOR 1

typedef uint16_t word_t;
typedef uint8_t byte_t;

#define INSTR_ENCODE(ex, i0, i1, fl, ou, cm) 0 | ((ex & 07) << 0) | ((i0 & 03) << 3) | ((i1 & 03) << 5) | ((fl & 01) << 7) | ((ou & 03) << 8) | ((cm & 63) << 10)

#define INSTR_GETEXEC(iword) (((iword) >> 0) & 07)
#define INSTR_GETI0(iword) (((iword) >> 3) & 03)
#define INSTR_GETI1(iword) (((iword) >> 5) & 03)
#define INSTR_GETFLAG(iword) (((iword) >> 7) & 01)
#define INSTR_GETOUT(iword) (((iword) >> 8) & 03)
#define INSTR_GETCMD(iword) (((iword) >> 10) & 63)

// Misuse the INSTR_ENCODE macro to create the bit masks :)
#define INSTR_MASK_EXEC INSTR_ENCODE(0xFFFF, 0, 0, 0, 0, 0)
#define INSTR_MASK_INPUT0 INSTR_ENCODE(0, 0xFFFF, 0, 0, 0, 0)
#define INSTR_MASK_INPUT1 INSTR_ENCODE(0, 0, 0xFFFF, 0, 0, 0)
#define INSTR_MASK_FLAG INSTR_ENCODE(0, 0, 0, 0xFFFF, 0, 0)
#define INSTR_MASK_OUTPUT INSTR_ENCODE(0, 0, 0, 0, 0xFFFF, 0)
#define INSTR_MASK_CMD INSTR_ENCODE(0, 0, 0, 0, 0, 0xFFFF)

#define INPUT_ZERO 0
#define INPUT_ARG 1
#define INPUT_PEEK 2
#define INPUT_POP 3

#define EXEC_ALWAYS 0
#define EXEC_ZERO 1
#define EXEC_NONZERO 2
#define EXEC_GREATER 3
#define EXEC_LESS 4
#define EXEC_GEQUAL 5
#define EXEC_LEQUAL 6
#define EXEC_NEVER 7

#define OUTPUT_DISCARD 0
#define OUTPUT_PUSH 1
#define OUTPUT_JUMP 2
#define OUTPUT_RJUMP 3

#define CMD_COPY 0
#define CMD_IPGET 1
#define CMD_GET 2
#define CMD_SET 3
#define CMD_STOR8 4
#define CMD_STOR16 5
#define CMD_LOAD8 6
#define CMD_LOAD16 7
// UNDEFINED        8
// UNDEFINED        9
#define CMD_FRGET 10
#define CMD_FRSET 11
#define CMD_BPGET 12
#define CMD_BPSET 13
#define CMD_SPGET 14
#define CMD_SPSET 15
#define CMD_ADD 16
#define CMD_SUB 17
#define CMD_MUL 18
#define CMD_DIV 19
#define CMD_MOD 20
#define CMD_AND 21
#define CMD_OR 22
#define CMD_XOR 23
#define CMD_NOT 24
#define CMD_NEG 25
#define CMD_ROL 26
#define CMD_ROR 27
#define CMD_BSWAP 28
#define CMD_ASR 29
#define CMD_LSL 30
#define CMD_LSR 31
