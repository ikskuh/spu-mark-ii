
LEX=flex
CC=gcc
LD=gcc
FLAGS=-O3 -Wall -Wextra -pedantic -I../include
CFLAGS=$(FLAGS)
LFLAGS=$(FLAGS)

all: assembler

assembler: lexer.yy.o
	$(LD) -o $@ $^

%.yy.c: %.l
	$(LEX) -o $@ -8 --yylineno --prefix="lex_" --interactive $<
	
%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<