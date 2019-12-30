%{
#include <stdio.h>
#include "assembler.h"

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
char string_buf[MAX_STR_CONST];
char *string_buf_ptr;
%}
%%

^{ws}\.org                          { return MKTOKEN(TOK_DIRECTIVE, DIR_ORG); }
^{ws}\.db                           { return MKTOKEN(TOK_DIRECTIVE, DIR_DB); }
^{ws}\.dw                           { return MKTOKEN(TOK_DIRECTIVE, DIR_DW); }
^{ws}\.align                        { return MKTOKEN(TOK_DIRECTIVE, DIR_ALIGN); }
^{ws}\.ascii                        { return MKTOKEN(TOK_DIRECTIVE, DIR_ASCII); }
^{ws}\.asciiz                       { return MKTOKEN(TOK_DIRECTIVE, DIR_ASCIIZ); }
^{ws}\.equ                          { return MKTOKEN(TOK_DIRECTIVE, DIR_EQU); }

\[{ws}ex{ws}:{ws}always{ws}\]   { return MKTOKEN(TOK_MOD_EX, EXEC_ALWAYS); }
\[{ws}ex{ws}:{ws}zero{ws}\]     { return MKTOKEN(TOK_MOD_EX, EXEC_ZERO); }
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
\[{ws}cmd{ws}:{ws}load8{ws}\]   { return MKTOKEN(TOK_MOD_CMD, CMD_LOAD8); }
\[{ws}cmd{ws}:{ws}load16{ws}\]  { return MKTOKEN(TOK_MOD_CMD, CMD_LOAD16); }
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
\[{ws}cmd{ws}:{ws}asr{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_ASR); }
\[{ws}cmd{ws}:{ws}lsl{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_LSL); }
\[{ws}cmd{ws}:{ws}lsr{ws}\]     { return MKTOKEN(TOK_MOD_CMD, CMD_LSR); }
\[{ws}cmd{ws}:{ws}bswap{ws}\]   { return MKTOKEN(TOK_MOD_CMD, CMD_BSWAP); }

,                               { return MKTOKEN(TOK_COMMA, 0); }
<INITIAL>\n                     { return MKTOKEN(TOK_NEWLINE, 0); }
<INITIAL>\\                     { return MKTOKEN(TOK_NEWLINE, 0); }

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

.                               { fprintf(stderr, "unknown char: '%s'\n", yytext); _abort(); }

%%
///////////////////////////////////////////////////////////////////////////////

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

struct {
	bool valid;
	uint16_t base;
	uint16_t mask;
	uint16_t over;
	uint16_t flags;
} currentInstruction;
	
void lex_assemble(FILE * infile)
{
	(void)input;
	(void)yyunput;
	
	yyin = infile;
	
	
	// initialize lexing with 1-lookahead
	lex();

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
								arg1 = _lexnum(&token, &patch1);
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
						// fprintf(stderr, "%s×%d", stringtable[mnemonic], argc);
						final = getMnemonic(stringtable[mnemonic], argc);
					}
					
					// fprintf(stderr, "[%04X,", final);
					
					final &= ~currentInstruction.mask;
					final |= (currentInstruction.over & currentInstruction.mask);
					
					/*fprintf(stderr, "%04X*%04X*→%04X]",*/
						/*currentInstruction.mask,*/
						/*currentInstruction.over,*/
						/*final);*/
					
					emit16(final);
					
					int realargc = (INSTR_GETI0(final) == INPUT_ARG)
						+ (INSTR_GETI1(final) == INPUT_ARG);
					if(realargc != argc) {
						fprintf(stderr, "Warning: argc mismatch!\n");
					}
					
					if(argc >= 1) {
						if(patch0 >= 0) {
							patch16(patch0);
							// fprintf(stderr, ",*%d", patch0);
						} else {
							emit16(arg0);
							// fprintf(stderr, ",%d", arg0);
						}
					}
					if(argc >= 2) {
						if(patch1 >= 0) {
							patch16(patch1);
							// fprintf(stderr, ",*%d", patch1);
						} else {
							emit16(arg1);
							// fprintf(stderr, ",%d", arg1);
						}
					}
					
					// fprintf(stderr, "\n");
					
					memset(&currentInstruction, 0, sizeof currentInstruction);
				}
				if(token.type != 0 && token.type != TOK_NEWLINE) {
					_abort();
				}
				break;
			}
		}
	} while(token.type != 0);
}
