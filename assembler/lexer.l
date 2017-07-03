
%{
#include <stdio.h>
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

#define MKTOKEN(type, val) (((type) & 0xFFFF0000) | ((val) & 0xFFFF))

#define _abort() do { fprintf(stderr, "abort in %s:%d!\n", __FILE__, __LINE__); abort(); } while(false)

int stringtable_len = 0;
char const * stringtable[(1<<16)] = { NULL };

char const * tokenNames[] = 
{
	"Unknown",
	"Directive",
	"Label",
	"Identifier",
	"Modifier(Execute)",
	"Modifier(Input 0)",
	"Modifier(Input 1)",
	"Modifier(Output)",
	"Modifier(Command)",
	"Modifier(Flag)",
	"Number",
	"Comma",
	"Newline",
	"String"
};

char string_buf[MAX_STR_CONST];
char *string_buf_ptr;

uint16_t registerString(char const * str, int len)
{
	if(stringtable_len >= (1<<16)) {
		_abort();
	}

	char * entry = malloc(len + 1);
	memcpy(entry, str, len);
	entry[len] = 0;
	
	for(int i = 0; i < stringtable_len; i++) {
		if(strcmp(stringtable[i], entry) == 0) {
			return i;
			free(entry);
		}
	}
	stringtable[stringtable_len] = entry;
	return stringtable_len++; // yes, this is hacky, but nice!
}

int escapeChar(char c)
{
	switch(c)
	{
		case 'a': return '\a';
		case 'b': return '\b';
		case 'e': return '\033'; // escape the reality!
		case 'f': return '\f';
		case 'n': return '\n';
		case 'r': return '\r';
		case 't': return '\t';
		case '\\': return '\\';
		case '\'': return '\'';
		case '\"': return '\"';
		case '\?': return '\?';
		default: _abort();
	}
}

%}

%option noyywrap
%s STRING

DIGIT              [0-9]
HEXDIGIT           [0-9A-Fa-f]
BINDIGIT           [0-1]
OCTDIGIT           [0-7]
ID                 [A-Za-z_][A-Za-z0-9_]*
WS                 [ \t]+
ws                 [ \t]*

%{
///////////////////////////////////////////////////////////////////////////////
%}
%%

^\.org                          { return MKTOKEN(TOK_DIRECTIVE, DIR_ORG); }
^\.db                           { return MKTOKEN(TOK_DIRECTIVE, DIR_DB); }
^\.dw                           { return MKTOKEN(TOK_DIRECTIVE, DIR_DW); }
^\.align                        { return MKTOKEN(TOK_DIRECTIVE, DIR_ALIGN); }
^\.ascii                        { return MKTOKEN(TOK_DIRECTIVE, DIR_ASCII); }
^\.asciiz                       { return MKTOKEN(TOK_DIRECTIVE, DIR_ASCIIZ); }
^\.equ                          { return MKTOKEN(TOK_DIRECTIVE, DIR_EQU); }

\[{ws}ex{ws}:{ws}always{ws}\]   { return MKTOKEN(TOK_MOD_EX, EXEC_ALWAYS); }
\[{ws}ex{ws}:{ws}zero{ws}\]     { return MKTOKEN(TOK_MOD_EX, EXEC_ALWAYS); }
\[{ws}ex{ws}:{ws}nonzero{ws}\]  { return MKTOKEN(TOK_MOD_EX, EXEC_NONZERO); }
\[{ws}ex{ws}:{ws}greater{ws}\]  { return MKTOKEN(TOK_MOD_EX, EXEC_GREATER); }
\[{ws}ex{ws}:{ws}less{ws}\]     { return MKTOKEN(TOK_MOD_EX, EXEC_LESS); }
\[{ws}ex{ws}:{ws}lequal{ws}\]   { return MKTOKEN(TOK_MOD_EX, EXEC_LEQUAL); }
\[{ws}ex{ws}:{ws}gequal{ws}\]   { return MKTOKEN(TOK_MOD_EX, EXEC_GEQUAL); }
\[{ws}ex{ws}:{ws}never{ws}\]    { return MKTOKEN(TOK_MOD_EX, EXEC_NEVER); }

\[{ws}i0{ws}:{ws}zero{ws}\]     { return MKTOKEN(TOK_MOD_I0, INPUT_ZERO); }
\[{ws}i0{ws}:{ws}arg{ws}\]      { return MKTOKEN(TOK_MOD_I0, INPUT_ARG); }
\[{ws}i0{ws}:{ws}peek{ws}\]     { return MKTOKEN(TOK_MOD_I0, INPUT_PEEK); }
\[{ws}i0{ws}:{ws}pop{ws}\]      { return MKTOKEN(TOK_MOD_I0, INPUT_POP); }

\[{ws}i1{ws}:{ws}zero{ws}\]     { return MKTOKEN(TOK_MOD_I1, INPUT_ZERO); }
\[{ws}i1{ws}:{ws}arg{ws}\]      { return MKTOKEN(TOK_MOD_I1, INPUT_ARG); }
\[{ws}i1{ws}:{ws}peek{ws}\]     { return MKTOKEN(TOK_MOD_I1, INPUT_PEEK); }
\[{ws}i1{ws}:{ws}pop{ws}\]      { return MKTOKEN(TOK_MOD_I1, INPUT_POP); }

\[{ws}out{ws}:{ws}discard{ws}\] { return MKTOKEN(TOK_MOD_OUT, OUTPUT_DISCARD); }
\[{ws}out{ws}:{ws}push{ws}\]    { return MKTOKEN(TOK_MOD_OUT, OUTPUT_PUSH); }
\[{ws}out{ws}:{ws}jmp{ws}\]     { return MKTOKEN(TOK_MOD_OUT, OUTPUT_JUMP); }
\[{ws}out{ws}:{ws}rjmp{ws}\]    { return MKTOKEN(TOK_MOD_OUT, OUTPUT_RJUMP); }

\[{ws}f{ws}:{ws}no{ws}\]        { return MKTOKEN(TOK_MOD_FLAG, 0); }
\[{ws}f{ws}:{ws}yes{ws}\]       { return MKTOKEN(TOK_MOD_FLAG, 1); }

\[{ws}cmd{ws}:{ws}copy{ws}\]    { return MKTOKEN(TOK_MOD_CMD, CMD_COPY); }
\[{ws}cmd{ws}:{ws}cpget{ws}\]   { return MKTOKEN(TOK_MOD_CMD, CMD_CPGET); }
\[{ws}cmd{ws}:{ws}get{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_GET); }
\[{ws}cmd{ws}:{ws}set{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_SET); }
\[{ws}cmd{ws}:{ws}stor8{ws}\]   { return MKTOKEN(TOK_MOD_CMD, CMD_STOR8); }
\[{ws}cmd{ws}:{ws}stor16{ws}\]  { return MKTOKEN(TOK_MOD_CMD, CMD_STOR16); }
\[{ws}cmd{ws}:{ws}setint{ws}\]  { return MKTOKEN(TOK_MOD_CMD, CMD_SETINT); }
\[{ws}cmd{ws}:{ws}int{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_INT); }
\[{ws}cmd{ws}:{ws}load8{ws}\]   { return MKTOKEN(TOK_MOD_CMD, CMD_LOAD8); }
\[{ws}cmd{ws}:{ws}load16{ws}\]  { return MKTOKEN(TOK_MOD_CMD, CMD_LOAD16); }
\[{ws}cmd{ws}:{ws}input{ws}\]   { return MKTOKEN(TOK_MOD_CMD, CMD_INPUT); }
\[{ws}cmd{ws}:{ws}output{ws}\]  { return MKTOKEN(TOK_MOD_CMD, CMD_OUTPUT); }
\[{ws}cmd{ws}:{ws}bpget{ws}\]   { return MKTOKEN(TOK_MOD_CMD, CMD_BPGET); }
\[{ws}cmd{ws}:{ws}bpset{ws}\]   { return MKTOKEN(TOK_MOD_CMD, CMD_BPSET); }
\[{ws}cmd{ws}:{ws}spget{ws}\]   { return MKTOKEN(TOK_MOD_CMD, CMD_SPGET); }
\[{ws}cmd{ws}:{ws}spset{ws}\]   { return MKTOKEN(TOK_MOD_CMD, CMD_SPSET); }
\[{ws}cmd{ws}:{ws}add{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_ADD); }
\[{ws}cmd{ws}:{ws}sub{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_SUB); }
\[{ws}cmd{ws}:{ws}mul{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_MUL); }
\[{ws}cmd{ws}:{ws}div{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_DIV); }
\[{ws}cmd{ws}:{ws}mod{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_MOD); }
\[{ws}cmd{ws}:{ws}and{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_AND); }
\[{ws}cmd{ws}:{ws}or{ws}\]      { return MKTOKEN(TOK_MOD_CMD, CMD_OR); }
\[{ws}cmd{ws}:{ws}xor{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_XOR); }
\[{ws}cmd{ws}:{ws}not{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_NOT); }
\[{ws}cmd{ws}:{ws}neg{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_NEG); }
\[{ws}cmd{ws}:{ws}rol{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_ROL); }
\[{ws}cmd{ws}:{ws}ror{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_ROR); }
\[{ws}cmd{ws}:{ws}asl{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_ASL); }
\[{ws}cmd{ws}:{ws}asr{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_ASR); }
\[{ws}cmd{ws}:{ws}lsl{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_LSL); }
\[{ws}cmd{ws}:{ws}lsr{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_LSR); }

,                               { return MKTOKEN(TOK_COMMA, 0); }
<INITIAL>\n                     { return MKTOKEN(TOK_NEWLINE, 0); }

^{ID}:                          { return MKTOKEN(TOK_LABEL, registerString(yytext, strlen(yytext) - 1)); }
{ID}                            { return MKTOKEN(TOK_IDENTIFIER, registerString(yytext, strlen(yytext))); }

0b{BINDIGIT}+                   { return MKTOKEN(TOK_NUMBER, strtol(yytext+2, NULL, 2)); }
0o{OCTDIGIT}+                   { return MKTOKEN(TOK_NUMBER, strtol(yytext+2, NULL, 8)); }
0x{HEXDIGIT}+                   { return MKTOKEN(TOK_NUMBER, strtol(yytext+2, NULL, 16)); }
-?{DIGIT}+                      { return MKTOKEN(TOK_NUMBER, atoi(yytext)); }

'\\.'                           { return MKTOKEN(TOK_NUMBER, escapeChar(yytext[2])); }
'.'                             { return MKTOKEN(TOK_NUMBER, yytext[1]); }

<INITIAL>\"                     { string_buf_ptr = string_buf; BEGIN(STRING); }

<STRING>\"                      { BEGIN(INITIAL);
																	*string_buf_ptr = '\0';
																	return MKTOKEN(TOK_STRING, registerString(string_buf, strlen(string_buf)));
																}
<STRING>\n                      { _abort(); }
<STRING>\\[0-7]{1,3}            {
																	/* octal escape sequence */
																	unsigned result;
																	(void) sscanf( yytext + 1, "%o", &result );
																	if (result > 0xff )
																		_abort();
																	*string_buf_ptr++ = result;
																}
<STRING>\\.                     { *string_buf_ptr++ = escapeChar(yytext[1]); }
<STRING>[^\\\n\"]+              { char *yptr = yytext;
																	while ( *yptr )
																		*string_buf_ptr++ = *yptr++;
																}

{WS}                            { /* ignore whitespace */ }

(;|#)[^\n]*                     { /* ignore comments */ }

.                               { _abort(); }

%%
///////////////////////////////////////////////////////////////////////////////
#include <unistd.h>

typedef struct label
{
	int name;
	uint16_t address;
	struct label * next;
} label_t;

label_t * labels = NULL;

void createLabel(int name, uint16_t location)
{
	label_t * it = labels;
	if(it == NULL) {
		it = malloc(sizeof(label_t));
		it->name = name;
		it->address = location;
		it->next = NULL;
		labels = it;
		return;
	}
	while(it->next != NULL) {
		if(it->name == name)
			_abort();
		it = it->next;
	}
	it->next = malloc(sizeof(label_t));
	it = it->next;
	
	it->name = name;
	it->address = location;
	it->next = NULL;
}

bool getLabel(int name, uint16_t * location)
{
	for(label_t * it = labels; it; it = it->next) {
		if(it->name != name)
			continue;
		*location = it->address;
		return true;
	}
	return false;
}

uint16_t getMnemonic(char const * name, int argc)
{
#define MNEMONIC(mnemonic,args,i0,i1,cmd,out,flag) \
	if(strcmp(name, #mnemonic) == 0 && argc == args) { \
		return INSTR_ENCODE(EXEC_ALWAYS, i0, i1, flag,out,cmd); \
	}
#include "mnemonics.h"
#undef MNEMONIC

	fprintf(stderr, "%s does not take %d arguments!\n", name, argc);

	_abort();
}

typedef struct token
{
	int type, value;
} token_t;

static struct token nextToken = { -1, -1 };

struct token peek()
{
	return nextToken;
}

struct token lex()
{
	struct token result = nextToken;
	if(result.type != 0)
	{
		int val = yylex();
		nextToken.type  = val & 0xFFFF0000;
		nextToken.value = val & 0x0000FFFF;
	}
	// fprintf(stderr, "[%d:%d]", result.type >> 16, result.value);
	return result;
}

struct {
	bool valid;
	uint16_t base;
	uint16_t mask;
	uint16_t over;
	uint16_t flags;
} currentInstruction;

typedef struct section
{
	uint16_t offset;
	uint16_t length;
	uint8_t * data;
	struct section * next;
} section_t;

section_t * currentSection = NULL;

typedef struct {
	int type; // 0 = label, 1 = expression
	section_t * section;
	uint16_t offset;
	int flags; // 1 = hasValue, 2 = hasAddress
	union {
		int name;
	};
} patch_t;

#define PATCH_REFERENCE  0
#define PATCH_EXPRESSION 1

patch_t patches[(1<<15)];
int patchCount = 0;

void emit8(uint8_t value)
{
	currentSection->data[currentSection->length++] = value;
	// fprintf(stderr, "%02X", value);
}

void emit16(uint16_t value)
{
	emit8((value >> 0) & 0xFF);
	emit8((value >> 8) & 0xFF);
}

void patch16(int patch)
{
	patches[patch].section = currentSection;
	patches[patch].offset  = currentSection->length;
	patches[patch].flags  |= 2;
	emit8(0xCC);
	emit8(0xCC);
}

int createPatch(int type)
{
	patches[patchCount].type = type;
	patches[patchCount].flags = 0;
	return patchCount++;
}

void createSection(uint16_t offset)
{
	if(currentSection != NULL && currentSection->length == 0) {
		section_t * temp = currentSection->next;
		free(currentSection->data);
		free(currentSection);
		currentSection = temp;
	}

	section_t * sect = malloc(sizeof(section_t));
	sect->next = currentSection;
	sect->offset = offset;
	sect->length = 0;
	sect->data = malloc(65536);
	
	currentSection = sect;
}

int _lexnum(struct token * token, int * patch)
{
	switch(token->type)
	{
		case TOK_NUMBER:
			return token->value;
		case TOK_IDENTIFIER: {
			// Check if we need a patch
			uint16_t address;
			if(getLabel(token->value, &address)) {
				return address;
			}
			if(patch == NULL) {
				fprintf(stderr, "Label references are not allowed here!\n");
				abort();
			}
			*patch = createPatch(PATCH_REFERENCE);
			patches[*patch].name = token->value;
			return 0xCCCC;
		}
		// TODO: Insert expression support!
		default:
			_abort();
	}
}

int lexnum(int * patch)
{
	// TODO: Implement patching, references and expressions here
	struct token tok = lex();
	return _lexnum(&tok, patch);
}

char const * lexstr()
{
	struct token tok = lex();
	if(tok.type != TOK_STRING) _abort();
	return stringtable[tok.value];
}

int lexid()
{
	struct token tok = lex();
	if(tok.type != TOK_IDENTIFIER) _abort();
	return tok.value;
}

void lexnl()
{
	struct token tok = lex();
	if(tok.type != TOK_NEWLINE) {
		fprintf(stderr, "Expected newline, got %s instead!", tokenNames[tok.type >> 16]);
		_abort();
	}
}

void lexcomma()
{
	struct token tok = lex();
	if(tok.type != TOK_COMMA) {
		fprintf(stderr, "Expected comma, got %s instead!", tokenNames[tok.type >> 16]);
		_abort();
	}
}

void generate_output();
void apply_patches();

int main(int argc, char ** argv)
{
	(void)input;
	(void)yyunput;
	int opt;
	while ((opt = getopt(argc, argv, "?o:")) != -1) {
		 switch (opt) {
		 case '?':
		 default: /* '?' */
				 fprintf(stderr, "Usage: %s source\n",
								 argv[0]);
				 exit(EXIT_FAILURE);
		 }
 }
 
 if (optind >= argc) {
		fprintf(stderr, "No input file!\n");
		exit(EXIT_FAILURE);
	}
	
	if(strcmp(argv[optind], "-") == 0) {
		yyin = stdin;
		fprintf(stderr, "Enter thy assembly:\n");
	} else {
		yyin = fopen(argv[optind], "r");
	}
	if(yyin == NULL) {
		fprintf(stderr, "Failed to open input file!\n");
		return EXIT_FAILURE;
	}
	
	// initialize lexing with 1-lookahead
	lex();
	
	// Create inital section
	createSection(0x0000);

	struct token token;
	do {
		token = lex();
		switch(token.type)
		{
			case TOK_DIRECTIVE: {
				switch(token.value)
				{
					case DIR_ORG:
						createSection(lexnum(NULL));
						lexnl();
						break;
					case DIR_DB:
						emit8(lexnum(NULL));
						while(peek().type == TOK_COMMA) {
							lex(); // consume comma
							emit8(lexnum(NULL));
						}
						lexnl();
						break;
					case DIR_DW: {
						int patch = -1;
						int val = lexnum(&patch);
						if(patch >= 0) patch16(patch);
						else emit16(val);
						while(peek().type == TOK_COMMA) {
							lex(); // consume comma
							
							patch = -1;
							val = lexnum(&patch);
							if(patch >= 0) patch16(patch);
							else emit16(val);
						}
						lexnl();
						break;
					}
					case DIR_ALIGN: {
						int alignment = lexnum(NULL);
						lexnl();
						currentSection->length = alignment * ((currentSection->offset + currentSection->length + alignment - 1) / alignment) - currentSection->offset;
						break;
					}
					case DIR_ASCII: {
						char const * str = lexstr();
						while(*str) {
							emit8(*str++);
						}
						break;
					}
					case DIR_ASCIIZ: {
						char const * str = lexstr();
						while(*str) {
							emit8(*str++);
						}
						emit8(0);
						break;
					}
					case DIR_EQU: {
						int name = lexid();
						int value = lexnum(NULL);
						createLabel(name, value);
						break;
					}
					default: _abort();
				}
				break;
			}
			case TOK_LABEL: {
				createLabel(token.value, currentSection->offset + currentSection->length);
				break;
			}
			default: {
				int mnemonic = -1;
				uint16_t arg0 = 0, arg1 = 0;
				int patch0 = -1, patch1 = -1;
				uint16_t state = 0;
				while(token.type != 0 && token.type != TOK_NEWLINE)
				{
					switch(token.type)
					{
						case TOK_MOD_EX:
							currentInstruction.valid = true;
							currentInstruction.mask |= INSTR_MASK_EXEC;
							currentInstruction.over |= INSTR_ENCODE(token.value, 0, 0, 0, 0, 0);
							break;
						case TOK_MOD_I0:
							currentInstruction.valid = true;
							currentInstruction.mask |= INSTR_MASK_INPUT0;
							currentInstruction.over |= INSTR_ENCODE(0, token.value, 0, 0, 0, 0);
							break;
						case TOK_MOD_I1:
							currentInstruction.valid = true;
							currentInstruction.mask |= INSTR_MASK_INPUT1;
							currentInstruction.over |= INSTR_ENCODE(0, 0, token.value, 0, 0, 0);
							break;
						case TOK_MOD_FLAG:
							currentInstruction.valid = true;
							currentInstruction.mask |= INSTR_MASK_FLAG;
							currentInstruction.over |= INSTR_ENCODE(0, 0, 0, token.value, 0, 0);
							break;
						case TOK_MOD_OUT:
							currentInstruction.valid = true;
							currentInstruction.mask |= INSTR_MASK_OUTPUT;
							currentInstruction.over |= INSTR_ENCODE(0, 0, 0, 0, token.value, 0);
							break;
						case TOK_MOD_CMD:
							currentInstruction.valid = true;
							currentInstruction.mask |= INSTR_MASK_CMD;
							currentInstruction.over |= INSTR_ENCODE(0, 0, 0, 0, 0, token.value);
							break;
						default:
							if(state == 0) {
								// pre-mnemonic
								if(token.type != TOK_IDENTIFIER)
									_abort();
								currentInstruction.valid = true;
								mnemonic = token.value;
								state = 1;
							} else if(state == 1) {
								// mnemonic 1
								arg0 = _lexnum(&token, &patch0);
								state = 2;
							} else if(state == 2) {
								// comma before argument 2
								if(token.type != TOK_COMMA)
									_abort();
								state = 3;
							} else if(state == 3) {
								// argument 2
								arg0 = _lexnum(&token, &patch1);
								state = 4;
							}
					}
					token = lex();
				}
				if(state == 3)
					_abort();
				if(currentInstruction.valid) {
					int argc = (state >= 2) + (state >= 4);
					uint16_t final = 0;
					if(mnemonic >= 0) {
						final = getMnemonic(stringtable[mnemonic], argc);
					}
					
					final &= ~currentInstruction.mask;
					final |= (currentInstruction.over & currentInstruction.mask);
					emit16(final);
					
					if(argc >= 1) {
						if(patch0 >= 0) {
							patch16(patch0);
						} else {
							emit16(arg0);
						}
					}
					if(argc >= 2) {
						if(patch1 >= 0) {
							patch16(patch1);
						} else {
							emit16(arg1);
						}
					}
					
					memset(&currentInstruction, 0, sizeof currentInstruction);
				}
				if(token.type != 0 && token.type != TOK_NEWLINE) {
					_abort();
				}
				break;
			}
		}
	} while(token.type != 0);
	
	apply_patches();
	
	generate_output();
	
	return 0;
}

void apply_patches()
{
	for(int i = 0; i < patchCount; i++)
	{
		uint16_t value;
		switch(patches[i].type)
		{
			case PATCH_REFERENCE: {
				if(getLabel(patches[i].name, &value) == false) {
					fprintf(stderr, "Could not find label %s\n", stringtable[patches[i].name]);
					_abort();
				}
				break;
			}
			// TODO: Insert expression support!
			default: _abort();
		}
		
		patches[i].section->data[patches[i].offset + 0]
			= ((value >> 0) & 0xFF);
		patches[i].section->data[patches[i].offset + 1]
			= ((value >> 8) & 0xFF);
	}
}

void generate_output()
{
	for(section_t * sect = currentSection; sect; sect = sect->next)
	{
		int start = sect->offset;
		int length = sect->length;
		uint8_t const * data = sect->data;
		while(length > 0)
		{
			if(start >= (1<<16))
				_abort();
			uint8_t len = 16;
			if(length < len) {
				len = length;
			}
			uint16_t pos = start;
			uint8_t checksum = len + (pos & 0xFF) + ((pos >> 8) & 0xFF);
			fprintf(stdout, ":%02X%04X00", len, pos);
			for(int i = 0; i < len; i++) {
				checksum += *data;
				fprintf(stdout, "%02X", *data++);
			}
			checksum = -checksum;
			fprintf(stdout, "%02X\n", checksum);
			
			start += len;
			length -= len;
		}
	}
	// End Marker
	fprintf(stdout, ":00000001FF\n");
}