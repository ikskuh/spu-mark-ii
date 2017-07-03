#include "assembler.h"

patch_t patches[(1<<15)];
int patchCount = 0;

int createPatch(int type)
{
	patches[patchCount].type = type;
	patches[patchCount].flags = 0;
	return patchCount++;
}

void apply_patches()
{
	for(int i = 0; i < patchCount; i++)
	{
		uint16_t value;
		switch(patches[i].type)
		{
			case PATCH_REFERENCE: {
				if(getLabel(patches[i].name, &value) == false) {
					fprintf(stderr, "Could not find label %s\n", stringtable[patches[i].name]);
					_abort();
				}
				break;
			}
			// TODO: Insert expression support!
			default: _abort();
		}
		
		patches[i].section->data[patches[i].offset + 0]
			= ((value >> 0) & 0xFF);
		patches[i].section->data[patches[i].offset + 1]
			= ((value >> 8) & 0xFF);
	}
}