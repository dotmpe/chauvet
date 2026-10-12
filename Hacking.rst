Dev notes
=========

Both Vim and Tmux repos are out of date, and much work is to do on this project.

rgb.txt reading and SVG/PNG renders are somewhat working, mostly.

Dependencies
------------
See requirements.apt.txt for Debian packages. Install apenwarr/redo manually.

- ``pouyakary/themeX`` for tmTheme (Visual Studio/Sublime/TextMate) highlight
  template conversions::

    npm install -g themex

- Python ``colormath`` and ``svgwrite``::

    python3 -m venv .venv
    source .venv/bin/activate
    pip install colormath svgwrite Pillow

Tools
-----
To run RGB.txt update::

  redo -k

To generate all artefacts (palette charts, var files)::

  redo -k @dist

To add parallelization add redo option ``-j<cores>``, where cores is the number of logical CPU available.
Use the ``nproc`` command or the equivalent ``grep -c ^processor /proc/cpuinfo`` to provide a cores value.

Status
------
- Current Chauvet is a selection from such X11 color set. Want to plot colors on
  diagrams (ie. LAB or HSV or whatever seems/feels suitable) and then select
  Chauvet colors in a more systematic way later. Current selection doesnt match
  perfectly to my liking and feels a bit awkward at times.

- Still would like to use a SASS inspired rule set.

  Need to map variables to properties in different structres efficiently,
  and SASS (normally used for CSS ie. DOM style attributes) seems like a good
  fit.

  SASS tooling was a bit of an experimental hack to have minimal deps at first, or in the basis. Instead of pulling in NodeJS/NPM, or finding and selecting a Python toolchain, just Bash would make the project work for the most basic CI/dev or source deployments.

  But sass.sh was never complete/bugfree. So need to review current setup, and for output templates as well.

- Initial redo setup is still simple, but applying parameters could use some rule system as well.
  See other work in +User-Scripts suite.

  XXX: Should trash Makefile as its an arcane format, but it documents some old,
  stale but unconsolidated recipes and work still

- ThemeX is another tool that promises a universal highlight colorscheme
  format. Uses a sensible YAML format. Tracking prototype with Git but have
  been looking to generate from sass.

Plan
-----
- Hope to move all style rules (ie. app themes) to Chauvet.sass
- Current color selection is for dark background, need to evaluate with light
  background more.

Current focus:

- Keeping as much of the redo build working, while integrating with
  better scripts from upstream and adding features.

- Some preliminary app config templates in ``tools/sh/*-e/*.tpl``...

- Current palette is not really adequate.
  Need color transform tool to give alternative versions for swatches, or
  even use more systematic approaches to generate ranges.

  Also, i.e. darker colors only work for users that have proper displays. For
  run- of-the-mill office and home budget displays could want to generate
  variant schemes that stay in "safe regions".


Project manifest
----------------
I want something very generic, and have not seen a lot of nice solutions.
For example and especially, Vim (which I'm very familiar with) I think has a
horribly basic theming system. Ok, things get better with plugins. And it is
hardly an issue unique to one editor. But both concepts like 'color', and that
of syntax highlighting (i.e. the choice of what code constructs you care about,
and how to set them apart from other constructs) all have a lot of nuances to
them and there is a big aspect of personal preference.

And I have not found this anywhere in as much detail as I'd like.
I've seen Base16, but I fail to see the point of prescribing 16 highlight
groups and also of redefining the basic palette.
Some kind of theme rules and config file template setup obviously has merit.


Implementation
--------------
The build process summarized in an outline of three steps:

1. generate SASS formatted color definitions from rgb.txt format
2. combine this file with any number of other SASS files containing styling
   rules, to apply the colors to any set of id, class and/or element selectors.
3. Use those SASS files as-is in systems that support it, as a selectable
   (user) theme. But more importantly for purposes of this project: to use as
   input to generate other more specific files.

Obviously, using only shell (Bash for now) as a prerequisite rather limits the
SASS expressions to some subset specifically formatted to be simple to parse.


Rules
-----
XXX: Any processor should be able to take the produced SASS and generate CSS from
it?

But to apply it to themeing something, obviously some structure of its own is
required.
Being generic however, such themeing should be easy apply.

to any to different highlight groups,
even GUI elements, and things we have not thought of yet.

The rules files use one Id type selector as the root for all of their rules.
There is no other metadata (yet), just a filename and the one id element
used as root. (But any metadata will probably be @field: tags in comments.)

This root has two main classes 'below' it:
one called ``.settings`` and one ``.rules``.

The classes below 'rules' correspond roughly to TextMate's old classication
hierarchy for source markup highlight and (some) GUI/editor stuff.
It was the only/most well-defined standard I could find.

Settings is there because I may want to allow further run-time configuration
of a theme, basing that on this part of the rules. But I'm not sure yet.


Templates
_________
Turns out there with eval-echo text can contain HERE docs.

Aside from that I think echo-e or cat-e templates should allow for the
same functionality.

----

TODO: using name attribute (among others) in SASS rules,
which are for sure not DOM/CSS standards compatible fields.
Unsure about how different SASS processor would fare.

..
