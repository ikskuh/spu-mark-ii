#include "minireadline.h"
#include "com.h"

#ifndef GNU_READLINE

static char linebuf[32];

char * readline(char const * prompt)
{
	com_puts(prompt);
	linebuf[0] = 0;
	for(int i = 0;;)
	{
		char c = com_getc();
		if(c == 13) {
			linebuf[i] = 0;
			break;
		}
		switch(c)
		{
			case -1: break;
			case 0x7F:
				if(i > 0) {
					linebuf[i--] = 0;
					com_putc('\b');
					com_putc(' ');
					com_putc('\b');
				}
				break;
			default:
				linebuf[i++] = c;
				com_putc(c);
				break;
		}
	}
	com_puts("\n\r");
	return linebuf;
}

#endif