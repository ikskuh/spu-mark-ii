#include <stdio.h>
#include <stdlib.h>

char * itoa(int value, char* str, int base) {
	switch(base) {
		case 10:
			sprintf(str, "%d", value);
			break;
		case 16:
			sprintf(str, "%04X", value);
			break;
		case 8:
			sprintf(str, "%o", value);
			break;
		default:
			abort();
	}
	return str;
}