#include "com.h"
#include <stdlib.h>
#include <stdio.h>

void com_putn(int value, int base)
{
	static char buf[64];
	switch(base) {
		case 8: sprintf(buf, "%o", value); break;
		case 16: sprintf(buf, "%X", value); break;
		default: sprintf(buf, "%d", value); break;
	}
	com_puts(buf);
}