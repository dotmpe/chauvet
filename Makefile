.PHONY: default check build dist
default: build

B ?= .chauvet/build
D ?= .chauvet/dist

#$(shell test -d $B || mkdir -p $B )
#$(shell	test -d $D || mkdir -p $D )

$B/rgbtxt/sass/root/%.sass:: %.rgb.txt tool/bash/rgb.sh
	test -d "${@D}" || mkdir -vp "${@D}"
	bash tool/bash/rgb.sh writeSass < $^ > $@

$D/Chauvet256dark.sass: $B/rgbtxt/sass/root/Chauvet.sass rules/*.sass
	cat $^ > $@

$D/Chauvet256dark.tab: $D/Chauvet256dark.sass sass.sh
	sass_quiet=1 bash sass.sh readTab < $< > $@

$D/Chauvet256dark.sh: $D/Chauvet256dark.sass sass.sh
	bash sass.sh readShSimpleVars < $< > $@

$D/Chauvet256.themex/theme.yml: $D/Chauvet256dark.tab
	mkdir -p $(shell dirname $@)
	bash sass.sh typeThemex < $< > $@

$D/Chauvet256dark.tmTheme: Chauvet.themex/builds/sublime/chauvet256dark.tmTheme
	cp $^ $@

Chauvet.themex/builds/sublime/chauvet256dark.tmTheme: Chauvet.themex/theme.yml
	themex Chauvet.themex

$D/Chauvet256dark.rasi: $D/Chauvet256dark.tab tools/sh/echo-e/rofi.rasi.tpl
	set -- $^; bash sass.sh typeTpl $$2 < $$1 > $@


check:: Chauvet.txt
	@rm .rgbcheck 2>/dev/null || true
	@python3 rgbtxt.py $^ >/dev/null 2>&1 | tee -a .rgbcheck
	@test ! -s .rgbcheck && echo check OK
	@rm .rgbcheck


#dist/Chauvet.themex/theme.yml

dist:: \
	$D/Chauvet256dark.sass \
	$D/Chauvet256dark.tmTheme

build:: check dist
