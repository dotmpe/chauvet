.PHONY: default build
default: build

rgb-check::
	rm .rgbcheck || true
	python3 rgbtxt.py 2> .rgbcheck
	test ! -s .rgbcheck
	rm .rgbcheck

Chauvet.themex/builds/sublime/chauvet256dark.tmTheme: Chauvet.themex/theme.yml
	themex Chauvet.themex

build:: rgb-check Chauvet.themex/builds/sublime/chauvet256dark.tmTheme
