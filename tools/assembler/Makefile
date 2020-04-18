
LEX=flex
CC=gcc
LD=gcc
FLAGS=-O3 -Wall -Wextra -pedantic -I../include
CFLAGS=$(FLAGS)
LFLAGS=$(FLAGS)

all: assembler

assembler: main.o lexer.yy.o codegen.o hexgen.o labels.o patches.o stringtable.o
	$(LD) -o $@ $^

%.yy.c: %.l
	$(LEX) -o $@ -8 --yylineno --prefix="lex_" --interactive $<
	
%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<