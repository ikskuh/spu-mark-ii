#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "assembler.h"

int main(int argc, char **argv)
{
	FILE *input = stdin, *output = stdout;
	int opt;
	bool symtable = false;
	while ((opt = getopt(argc, argv, "?so:")) != -1)
	{
		switch (opt)
		{
		case 's':
			symtable = true;
			break;
		case 'o':
			output = fopen(optarg, "w");
			if (output == NULL)
			{
				fprintf(stderr, "Output file '%s' not found!\n", optarg);
				exit(EXIT_FAILURE);
			}
			break;
		case '?':
		default: /* '?' */
			fprintf(stderr, "Usage: %s source\n",
							argv[0]);
			exit(EXIT_FAILURE);
		}
	}

	if (optind >= argc)
	{
		fprintf(stderr, "No input file!\n");
		exit(EXIT_FAILURE);
	}

	if (strcmp(argv[optind], "-") == 0)
	{
		input = stdin;
	}
	else
	{
		input = fopen(argv[optind], "r");
	}
	if (input == NULL)
	{
		fprintf(stderr, "Failed to open input file!\n");
		return EXIT_FAILURE;
	}

	// Create inital section
	createSection(0x0000);

	lex_assemble(input);

	apply_patches();

	generate_output(output);

	if (symtable)
	{
		for (label_t *it = getLabelIt(); it; it = it->next)
		{
			fprintf(stderr, "%s\t%04X\n", stringtable[it->name], it->address);
		}
	}

	return 0;
}