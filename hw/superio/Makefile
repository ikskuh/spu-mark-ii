
LIBPATH=/home/felix/projects/spin-standard-library/library
ROOTFILE=superio.spin
OUTFILE=$(ROOTFILE:.spin=.binary)
SERPORT=/dev/ttyUSB0

all: $(OUTFILE)

%.binary: %.spin
	openspin -q -I $(LIBPATH) -b $<

program: $(OUTFILE)
	proploader -p $(SERPORT) -Rsre $<

run: $(OUTFILE)
	proploader -p $(SERPORT) -Rsr $<

debug: run
	picocom -b 115200 $(SERPORT)

.SUFFIXES:
.PHONY: run program