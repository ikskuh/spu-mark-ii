# requires
# - pandoc
# - cp
# - cat

PAGE_PROLOGUE=template/page.htm.prologue
PAGE_EPILOGUE=template/page.htm.epilogue
PAGES=index downloads documentation livedemo
FILES=style.css

all: website


website: $(addprefix output/,$(addsuffix .htm,$(PAGES)) $(FILES)) 

output/%.htm: template/pages/%.md
	cat "$(PAGE_PROLOGUE)" > $@
	pandoc "$<" >> $@
	cat "$(PAGE_EPILOGUE)" >> $@

output/%.htm: template/pages/%.htm
	cat "$(PAGE_PROLOGUE)" > $@
	cat "$<" >> $@
	cat "$(PAGE_EPILOGUE)" >> $@

output/%: content/%
	cp -r "$<" "$@"

.PHONY: all
.SUFFIXES: