#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <spu-2.h>

#define MAX_STR_CONST  4096

#define TOK_DIRECTIVE  0x10000 // val = directive id
#define TOK_LABEL      0x20000 // val = string index
#define TOK_IDENTIFIER 0x30000 // val = string index
#define TOK_MOD_EX     0x40000 // val = bitfield
#define TOK_MOD_I0     0x50000 // ...
#define TOK_MOD_I1     0x60000 //
#define TOK_MOD_OUT    0x70000 //
#define TOK_MOD_CMD    0x80000 //
#define TOK_MOD_FLAG   0x90000 //
#define TOK_NUMBER     0xA0000 // val = 16 bit number
#define TOK_COMMA      0xB0000 // val = 0
#define TOK_NEWLINE    0xC0000 // val = 0
#define TOK_STRING     0xD0000 // val = 0
// TODO: Insert formula support later!

#define DIR_ORG    0
#define DIR_DB     1
#define DIR_DW     2
#define DIR_ALIGN  3
#define DIR_ASCII  4
#define DIR_ASCIIZ 5
#define DIR_EQU    6

#define PATCH_REFERENCE  0
#define PATCH_EXPRESSION 1

#define MKTOKEN(type, val) (((type) & 0xFFFF0000) | ((val) & 0xFFFF))

#define _abort() do { fprintf(stderr, "abort in %s:%d!\n", __FILE__, __LINE__); abort(); } while(false)

typedef struct token
{
	int type, value;
} token_t;

typedef struct label
{
	int name;
	uint16_t address;
	struct label * next;
} label_t;

typedef struct section
{
	uint16_t offset;
	uint16_t length;
	uint8_t * data;
	struct section * next;
} section_t;

typedef struct {
	int type; // 0 = label, 1 = expression
	section_t * section;
	uint16_t offset;
	int flags; // 1 = hasValue, 2 = hasAddress
	union {
		int name;
	};
} patch_t;

extern char const * stringtable[];

// lexer.yy.c
void lex_assemble(FILE * input);

// codegen.c
extern section_t * currentSection;
void emit8(uint8_t value);
void emit16(uint16_t value);
void patch16(int patch);
void createSection(uint16_t offset);

// hexgen.c
void generate_output(FILE * target);

// patches.c
extern patch_t patches[];
void apply_patches();
int createPatch(int type);

// stringtable.c
uint16_t registerString(char const * str, int len);

// labels.c
void createLabel(int name, uint16_t location);
bool getLabel(int name, uint16_t * location);
label_t * getLabelIt();