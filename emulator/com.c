#include "com.h"
#include "stdlib.h"

char * itoa(int value, char * , int base);

void com_putn(int value, int base)
{
	static char buf[64];
	com_puts(itoa(value, buf, base));
}