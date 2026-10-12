---
title: Xorg rgb.txt notes
category: [notes]
status: idea
---

An X11 rgb.txt file has three columns with 0-255 values for R, G and B,
channels, followed by a name for ID.
The exact format that Chauvet relies on is documented in the [rgb.txt conventions](RGB_CONVENTIONS.md) document.
This document has additional notes on the specific format and its use.

The main file defining colors for the local server is normally found at `/etc/X11/rgb.txt`.
But my Linux laptop has tens of copies of them, many of which are the same or almost similar.
But not all; it would be interesting to map the profiles in the Chauvet project as well.

Most of the input is not very clean.
Often lines are duplicated, only to provide for different notations of the name.
For example: 'medium spring green' and 'mediumSpringGreen'.

Comments appear both as '! ' and '#' prefixed lines (but I did not exactly check that).

For a normal, modern and capable setup there may be hundreds or more colors defined;
in theory, at 8 bits/channel there are over ~16.7M possible entries, not including aliases.

These define color as standard RGB values, uncorrected for specific hardware or light conditions, etc.
Read the appendix of `rgb.txt conventions` on color spaces for more information.
