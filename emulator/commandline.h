#pragma once

#include "com.h"

struct cmd
{
	char const * name;
	char const * description;
	int argc;
	void (*execute)(int * args);
	struct cmd * next;
};

void commandline_open(char const * prompt);

void command_register(struct cmd * cmd);

#define REGISTER_COMMAND(Name, Desc, Cmd, Len) \
	static struct cmd _command_##Name = { \
		#Name, Desc, Len, &Cmd, NULL \
	}; \
	static void __attribute__((constructor)) _init_##Name() { \
		command_register(&_command_##Name); \
	}


#define CONSOLECOMMAND(Name, Len, Desc) \
	static void _cmd_##Name(int * args); \
	static struct cmd _cmdreg_##Name = { \
		#Name, Desc, Len, &_cmd_##Name, NULL \
	}; \
	static void __attribute__((constructor)) _init_##Name() { \
		command_register(&_cmdreg_##Name); \
	} \
	static void _cmd_##Name(int * args)
