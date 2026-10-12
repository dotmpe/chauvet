---
title: Chauvet theme and color toolkit project conventions
status: draft
category: [conventions]
---

Goal: make color themeing more easy.

# Objectives
- I/O with common color formats:

  - X11 rgb.txt file,
  - TextMate support (and Sublime and other editor/app/picker/toolchain suites) for most coverage.

- Some way to record mappings of abstracts (syntax, backgrounds, chrome
  elements, and states) to palette swatches. And work towards a scheme to cover
  the desktop, terminal and web domains cq. different platforms.

- Generate flat formats but also (templated) scripts, for adaptive themeing.

- Do some intro docs/scripting for perception testing, calibration, science
  behind color (CIE/ICC).

- Document various other common or popular palettes and themes I like, and
  incorporate and use them as source just like Chauvet itself.

- Help to solve building a unified color theme experience on Linux/X11, with
  support for light and dark (and perhaps other parametric) variation.

For more, the old Hacking.rst has all the (very unorganized) dev notes.
This document and project setup should follow the User-Tools suite (+User-Scripts etc.) of projects later,
but for now the build is isolated and non-CI, hardcoded into .env.sh.

New documents should be written in markdown.
Overall project history should be documented in [Chauvet theme project history](CHAUVET_HISTORY.md).

Work done on the project should be reflected not just in source and config files.
But as well in updated conventions, tasks, and tests; to track data, code and
related ideas and references in history effectively.

Tasks are kept in TODO.txt files, and closed when done.
(See also sub-projects for TODO's)

The toolchain choices should be restricted to Bash, Python, or alternatively branch to something more simple (ie. Lua based, or some ready-made, widely deployable third party suite or project).

For most up to date status, refer still to Hacking.rst
