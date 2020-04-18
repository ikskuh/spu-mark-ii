#include "assembler.h"

#include <stdio.h>

void generate_output(FILE * target)
{
	for(section_t * sect = currentSection; sect; sect = sect->next)
	{
		int start = sect->offset;
		int length = sect->length;
		uint8_t const * data = sect->data;
		while(length > 0)
		{
			if(start >= (1<<16))
				_abort();
			uint8_t len = 16;
			if(length < len) {
				len = length;
			}
			uint16_t pos = start;
			uint8_t checksum = len + (pos & 0xFF) + ((pos >> 8) & 0xFF);
			fprintf(target, ":%02X%04X00", len, pos);
			for(int i = 0; i < len; i++) {
				checksum += *data;
				fprintf(target, "%02X", *data++);
			}
			checksum = -checksum;
			fprintf(target, "%02X\n", checksum);
			
			start += len;
			length -= len;
		}
	}
	// End Marker
	fprintf(target, ":00000001FF\n");
}