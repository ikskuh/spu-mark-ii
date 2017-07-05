#pragma once

#ifdef __AVR_GCC__

char * readline(char const * prompt);
#define READLINE(prompt) readline(prompt)
#define CLEARLINE(result)

#else

#ifdef GNU_READLINE

#include <stdio.h>
#include <readline/readline.h>
#include <readline/history.h>

#define READLINE(prompt) readline(prompt)
#define CLEARLINE(result) free(result)

#else

char * readline(char const * prompt);
#define READLINE(prompt) readline(prompt)
#define CLEARLINE(result)

#endif

#endif