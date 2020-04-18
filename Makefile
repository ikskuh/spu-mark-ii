


all: soc tools

soc:
	$(MAKE) -C soc

tools:
	$(MAKE) -C tools

.PHONY: soc tools
.SUFFIXES: