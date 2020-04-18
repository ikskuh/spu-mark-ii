#include "assembler.h"

#include <string.h>

int stringtable_len = 0;
char const * stringtable[(1<<16)] = { NULL };

uint16_t registerString(char const * str, int len)
{
	if(stringtable_len >= (1<<16)) {
		_abort();
	}

	char * entry = malloc(len + 1);
	memcpy(entry, str, len);
	entry[len] = 0;
	
	for(int i = 0; i < stringtable_len; i++) {
		if(strcmp(stringtable[i], entry) == 0) {
			return i;
			free(entry);
		}
	}
	stringtable[stringtable_len] = entry;
	return stringtable_len++; // yes, this is hacky, but nice!
}