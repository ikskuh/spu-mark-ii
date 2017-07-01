#pragma once

#define INPUT_ZERO 0
#define INPUT_ARG  1
#define INPUT_PEEK 2
#define INPUT_POP  3

#define EXEC_ALWAYS  0
#define EXEC_ZERO    1
#define EXEC_NONZERO 2
#define EXEC_GREATER 3
#define EXEC_LESS    4
#define EXEC_GEQUAL  5
#define EXEC_LEQUAL  6
#define EXEC_NEVER   7

#define OUTPUT_DISCARD 0
#define OUTPUT_PUSH    1
#define OUTPUT_JUMP    2
#define OUTPUT_RJUMP   3

#define CMD_COPY    0
#define CMD_CPGET   1
#define CMD_GET     2
#define CMD_SET     3
#define CMD_STOR8   4
#define CMD_STOR16  5
#define CMD_SETINT  6
#define CMD_INT     7
#define CMD_LOAD8   8
#define CMD_LOAD16  9
#define CMD_INPUT  10
#define CMD_OUTPUT 11
#define CMD_BPGET  12
#define CMD_BPSET  13
#define CMD_SPGET  14
#define CMD_SPSET  15

#define CMD_ADD    16
#define CMD_SUB    17
#define CMD_MUL    18
#define CMD_DIV    19
#define CMD_MOD    20
#define CMD_AND    21
#define CMD_OR     22
#define CMD_XOR    23
#define CMD_NOT    24
#define CMD_NEG    25
#define CMD_ROL    26
#define CMD_ROR    27
#define CMD_ASL    28
#define CMD_ASR    29
#define CMD_LSL    30
#define CMD_LSR    31
