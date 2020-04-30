# requires
# - pandoc
# - cp
# - cat

PAGE_PROLOGUE=template/page.htm.prologue
PAGE_EPILOGUE=template/page.htm.epilogue
DOC_TEMPLATE=template/doc.htm
PAGES=index downloads documentation livedemo docs/isa docs/an000 docs/an001 docs/an002 docs/an003 imprint privacy
FILES=style.css base16-summerfruit-dark.css \
	emulator.wasm livedemo.js \
	xterm/xterm.js xterm/xterm.css \
	downloads/ashet-toolchain-windows-x86_64.zip \
	downloads/ashet-toolchain-linux-x86_64.zip \
	downloads/emulator-linux-x86_64 \
	downloads/assembler-linux-x86_64 \
	downloads/disassembler-linux-x86_64 \
	downloads/debugger-linux-x86_64 \
	downloads/emulator-windows-x86_64.exe \
	downloads/assembler-windows-x86_64.exe \
	downloads/disassembler-windows-x86_64.exe \
	downloads/debugger-windows-x86_64.exe

all: website

deploy: website
	scp -i ~/.ssh/id_ashet -r output/* ashet-ci@ashet.computer:website

website: folders $(addprefix output/,$(addsuffix .htm,$(PAGES)) $(FILES)) 

folders:
	mkdir -p output
	mkdir -p $(addprefix output/,docs downloads xterm)

output/%.htm: template/pages/%.md $(PAGE_EPILOGUE) $(PAGE_PROLOGUE)
	cat "$(PAGE_PROLOGUE)" > $@
	pandoc "$<" >> $@
	cat "$(PAGE_EPILOGUE)" >> $@

output/%.htm: template/pages/%.htm $(PAGE_EPILOGUE) $(PAGE_PROLOGUE)
	cat "$(PAGE_PROLOGUE)" > $@
	cat "$<" >> $@
	cat "$(PAGE_EPILOGUE)" >> $@

output/%: content/%
	cp -r "$<" "$@"

output/emulator.wasm: ../zig-cache/lib/emulator.wasm
	cp "$<" "$@"

output/docs/isa.htm: ../documentation/isa.md $(DOC_TEMPLATE)
	pandoc --standalone --template=$(DOC_TEMPLATE) --metadata-file=template/metadata/$(notdir $(@:.htm=.yaml)) --from gfm --to html --toc "$<" > $@

output/docs/an000.htm: ../documentation/app-notes/AN000\ -\ Understanding\ the\ Instruction\ Set.md $(DOC_TEMPLATE) 
	pandoc --standalone --template=$(DOC_TEMPLATE) "--metadata-file=template/metadata/$(notdir $(@:.htm=.yaml))" --from gfm --to html --toc "$<" > $@

output/docs/an001.htm: ../documentation/app-notes/AN001\ -\ The\ SPU\ Assembly\ Language.md $(DOC_TEMPLATE)
	pandoc --standalone --template=$(DOC_TEMPLATE) "--metadata-file=template/metadata/$(notdir $(@:.htm=.yaml))" --from gfm --to html --toc "$<" > $@
	
output/docs/an002.htm: ../documentation/app-notes/AN002\ -\ Standard\ Calling\ Convention.md $(DOC_TEMPLATE)
	pandoc --standalone --template=$(DOC_TEMPLATE) "--metadata-file=template/metadata/$(notdir $(@:.htm=.yaml))" --from gfm --to html --toc "$<" > $@
	
output/docs/an003.htm: ../documentation/app-notes/AN003\ -\ Writing\ efficient\ code.md $(DOC_TEMPLATE)
	pandoc --standalone --template=$(DOC_TEMPLATE) "--metadata-file=template/metadata/$(notdir $(@:.htm=.yaml))" --from gfm --to html --toc "$<" > $@
	
output/downloads/ashet-toolchain-windows-x86_64.zip: 
	zip "$@" ../build/x86_64-windows/{*.exe,*.pdb}

output/downloads/ashet-toolchain-linux-x86_64.zip: 
	zip "$@" $(filter-out %.o,$(wildcard ../build/x86_64-linux/*))

output/downloads/%-windows-x86_64.exe: ../build/x86_64-windows/%.exe
	cp "$<" "$@"

output/downloads/%-linux-x86_64: ../build/x86_64-linux/%
	cp "$<" "$@"

.PHONY: all folders deploy
.SUFFIXES: