Chauvet theme files
===================
:Created: 2022-03-30

A bright orange color theme.

These theme files use fonts patched for `Powerline extra symbols` (see `NERD fonts`_).

Status: under development.
See `chauvet-vim </dotmpe/chauvet-vim>`__ for the current visual impression.

The Vim and Tmux config files should be usable.

- `Vim colorscheme <chauvet-vim>`_
- `Tmux statusbar <chauvet-tmux>`_

More is in the making.

Best format to write style rules, is of course CSS.
I hope use a CSS or SASS subset for configuration, and some simple template
format to generate application specific color themes without any other
dependencies than a shell.

Also I want to convert colors according to LAB\ [#]_ (and other human-perception
models), probably using Python, to generate variant color schemes on Chauvet
and possibly others.

See Hacking.rst for current development notes.

.. _Powerline extra symbols: https://github.com/ryanoasis/powerline-extra-symbols
.. _Nerd fonts: https://nerdfonts.com
.. [#] <https://legacy.imagemagick.org/Usage/color_basics/#colorspace_LAB>
..
