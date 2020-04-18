#include "assembler.h"

section_t * currentSection = NULL;

void emit8(uint8_t value)
{
	currentSection->data[currentSection->length++] = value;
	// fprintf(stderr, "%02X", value);
}

void emit16(uint16_t value)
{
	emit8((value >> 0) & 0xFF);
	emit8((value >> 8) & 0xFF);
}

void patch16(int patch)
{
	patches[patch].section = currentSection;
	patches[patch].offset  = currentSection->length;
	patches[patch].flags  |= 2;
	emit8(0xCC);
	emit8(0xCC);
}

void createSection(uint16_t offset)
{
	if(currentSection != NULL && currentSection->length == 0) {
		section_t * temp = currentSection->next;
		free(currentSection->data);
		free(currentSection);
		currentSection = temp;
	}

	section_t * sect = malloc(sizeof(section_t));
	sect->next = currentSection;
	sect->offset = offset;
	sect->length = 0;
	sect->data = malloc(65536);
	
	currentSection = sect;
}




