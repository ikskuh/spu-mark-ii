#include "assembler.h"

static label_t * labels = NULL;

label_t * getLabelIt() { return labels; }

void createLabel(int name, uint16_t location)
{
	label_t * it = labels;
	if(it == NULL) {
		it = malloc(sizeof(label_t));
		it->name = name;
		it->address = location;
		it->next = NULL;
		labels = it;
		return;
	}
	while(it->next != NULL) {
		if(it->name == name)
			_abort();
		it = it->next;
	}
	it->next = malloc(sizeof(label_t));
	it = it->next;
	
	it->name = name;
	it->address = location;
	it->next = NULL;
}

bool getLabel(int name, uint16_t * location)
{
	for(label_t * it = labels; it; it = it->next) {
		if(it->name != name)
			continue;
		*location = it->address;
		return true;
	}
	return false;
}