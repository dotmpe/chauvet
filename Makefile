.PHONY: default check build dist
default: build

$(shell test -d build || mkdir build )
$(shell	test -d dist || mkdir dist )


build/Chauvet-colors.sass: Chauvet.txt rgb.sh
	bash rgb.sh writeSass < $^ > $@

dist/Chauvet256dark.sass: build/Chauvet-colors.sass rules/*.sass
	cat $^ > $@

dist/Chauvet256dark.tab: dist/Chauvet256dark.sass sass.sh
	sass_quiet=1 bash sass.sh readTab < $< > $@

dist/Chauvet256dark.sh: dist/Chauvet256dark.sass sass.sh
	bash sass.sh readShSimpleVars < $< > $@

dist/Chauvet256.themex/theme.yml: dist/Chauvet256dark.tab
	mkdir -p $(shell dirname $@)
	bash sass.sh typeThemex < $< > $@

#dist/Chauvet256dark.tmTheme: Chauvet.themex/builds/sublime/chauvet256dark.tmTheme
#	cp $^ $@

Chauvet.themex/builds/sublime/chauvet256dark.tmTheme: Chauvet.themex/theme.yml
	themex Chauvet.themex

dist/Chauvet256dark.rasi: dist/Chauvet256dark.tab tools/sh/echo-e/rofi.rasi.tpl
	set -- $^; bash sass.sh typeTpl $$2 < $$1 > $@


check:: Chauvet.txt
	@rm .rgbcheck 2>/dev/null || true
	@python3 rgbtxt.py $^ >/dev/null 2>&1 | tee -a .rgbcheck
	@test ! -s .rgbcheck && echo check OK
	@rm .rgbcheck


#dist/Chauvet.themex/theme.yml

dist:: \
	dist/Chauvet256dark.sass \
	dist/Chauvet256dark.tmTheme

build:: check dist
