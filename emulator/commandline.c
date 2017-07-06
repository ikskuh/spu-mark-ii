#include "commandline.h"
#include "com.h"
#include "minireadline.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

char *  itoa ( int value, char * str, int base );

static struct cmd * firstCommand = NULL;
static char buffer[64];

void command_register(struct cmd * cmd)
{
	cmd->next = firstCommand;
	firstCommand = cmd;
}

void commandline_open(char const * prompt)
{
	char * linebuf = READLINE(prompt);
	
	char const * cmd = linebuf;
	int arguments[4];
	int argc = 0;
	do
	{
		char * p = linebuf;
		while(isalnum(*p)) p++;
		if(*p == 0) break;
		*p++ = 0;
		// start parsing args
		while(*p)
		{
			while(isblank(*p)) p++;
			char * str = p;
			while(*p == '$' || isalnum(*p)) p++;
			if(*str == '$') {
				arguments[argc++] = strtol(str + 1, NULL, 16);
			} else {
				arguments[argc++] = strtol(str, NULL, 10);
			}
			if(*p == 0) break;
			*p++ = 0;
		}
	} while(false);
	
	struct cmd * it = firstCommand;
	while(it != NULL)
	{
		if(strcmp(it->name, cmd)) {
			it = it->next;
			continue;
		}
		if(it->argc != argc) {
			com_puts("Command ");
			com_puts(cmd);
			com_puts(" takes ");
			com_puts(itoa(it->argc, buffer, 10));
			com_puts(" arguments!\n\r");
		} else {
			it->execute(arguments);
		}
		break;
	}
	if(it == NULL) {
		com_puts("Command `");
		com_puts(cmd);
		com_puts("` does not exist!\n\r");
	}
	CLEARLINE(linebuf);
}

static void cmd_help(int * args)
{
	(void)args;
	for(struct cmd * it = firstCommand; it; it = it->next)
	{
		com_puts(it->name);
		com_putc('\t');
		com_puts(it->description);
		com_puts("\r\n");
	}
}

REGISTER_COMMAND(help, "Lists all available commands.", cmd_help, 0)