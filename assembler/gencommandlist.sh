#/!bin/bash
grep CMD_ ../include/spu-2.h \
	| sed "s|.*CMD_||" \
	| sed "s|\s.*||" \
	| awk '{ print "\\[{ws}cmd{ws}:{ws}" tolower($1) "{ws}\\] { return MKTOKEN(TOK_MOD_CMD, CMD_" $1 "); }" }'