---
title: rgb.txt file format conventions
category: [conventions]
status: draft
---

This document describes an rgb.txt file format and related TSV profiles used by the Chauvet project.
The purpose is to have one common, readable and editable notation that is easy to compare and that can hold additional data.

# Conventional and project usage
The purpose of rgb.txt is to define colors for a graphical window server.
This input data and its format is adopted here for use as a simple notation for custom palettes (a set of colors and names), as well as renderings of a more complex theme or style.

The source and reference palettes cq. themes are all stored in a TSV derived format.
Their normal location is the directory `src/rgbtab/`.
The non-standard extension `.rgb.tsv` and MIME type `text/tab-separated-values;profile=rgb` may be used orthogonally.

These data files are adjusted for maximum reference value, and store denormalized or redundant notations.
This format is not directly compatible with X11 `rgb.txt` files, but it may be filtered by inserting or removing the double TAB for a single TAB--with additional provisions.
For more info see the per-format sections and the appendix on TSV profiles or related file formats.

# The standard RGB.txt format

A conventional X11 `rgb.txt` file has columns for red, green, and blue channel values, followed by a color name.

The RGB values are integers in the range 0–255, representing the 8-bit channel values of one color.
These RGB columns are space separated and may be further padded left or right.

The name is separated from the RGB values by two TAB characters, or follows after them, and must be present.

There are no comments or other provisions.

For additional notes, see [Xorg rgb.txt notes](XORG_RGBTXT.md).

With additional provisions, the format should be loadable by a TSV parser.
The profile `rgbtxt` may be used if it matches the classic X11 rgb.txt layout:

- the initial field are three space-separated and optionally padded 8-bit decimals for RGB,
- the second is empty,
- and the third is a string for color name.

For additional TSV profiles see the table in the appendix.

# Extensions for the Chauvet project

## Standard comment lines
Comments are line based.
The parser should handle prefix selection, with `;` normally being used for Chauvet assets.

For example, `!` may be used in X11 configuration contexts;
and `#` should be used for generic TSV consumers.

## Embedded metadata in comments

Metadata is tracked in special comments, like this (adapted of `Chauvet.rgb.txt` itself):

```rgb.txt
; @version: 0.0.1-dev
; @author: .mpe
; @name: Chauvet 256
; @description: Bright orange
; @baseColor: dark
; @colorSpaceName: sRGB
; @UUID: a2584019-ef05-4989-b06a-905edfbd1f06
```

## Additional data in tab separated column fields

The remaining data fields are TAB-separated (unlike the RGB channel fields).
The parser must interpret an empty first field as a standard rgb.txt entry, but should not use it for output.

Values may still be padded with spaces.

The following additional columns are recognized by the Chauvet build after the name column:

- alternative hex notation of the RGB value, concatenated as a standard six-character hexadecimal string,
- xterm-256 index (if applicable),
- comment/description.

## Additional restrictions

By convention, Chauvet itself only uses and loads strict color names ([A-Za-z_][A-Za-z0-9_]+).

# Appendix

## Additional profiles for tab-separated data files

| Name extension | MIME type | Notes |
| --- | --- | --- |
| .rgb.tsv | text/tab-separated-values;profile=rgb | As described in document |
| .rgb.txt | text/tab-separated-values;profile=rgbtxt | The values and layout must match a RGB.txt |
| .rgbhex.txt | text/tab-separated-values;profile=rgbhex | The decimal column may be replaced by a hexadecimal, with optional spaces, and the rgbhex extension column is dropped when present |
| .rgba.tsv | text/tab-separated-values;profile=rgba | Hold an additional 8 bit for the alpha blending value |
| .rgba.txt | text/tab-separated-values;profile=rgbatxt | |
| .rgbahex.txt | text/tab-separated-values;profile=rgbahex | |

The rgb variants all hold 24 bit color definitions, and metadata annotation.

When an alpha channel is needed the above rgba profiles can hold 32 bit color definitions.

Some formats may use 3-digit hexademicals, or other and even more restricted color ranges.
Such may be added later to the fields for the Chauvet project format.

(XXX: urwid has a few nice demos of other, <8bit/ch color palettes, to see how they
map and along with the name/index schemes for those.)

## Color space and jargon

For universal color definitions the CIE (Vienna based non-profit est. 1900/1913) and ICC (industry body est. 1993) provide the backbone;
CIE for the scientific definitions, and ICC for profiles that can accurately characterize devices and allow for correction.

Color is a highly subjective perception, and the human brain plays a big part in processing a "signal" including adaption or filtering.
As well as the exact cell morphism and lens, those all influence sensitivity and degrade by age.

Individual differences are large and local but reliable and partially understood.
The CIE defines a *colorimetric science* for how light is perceived, it has models for perception reduced with feedback from ~10 observers and for physical light itself.

ICC is how the industry provides the profile that use these perceptual models of CIE (CIE XYZ and CIELAB) to describe and calibrate devices.
A ICC profile has a PCS (profile connection space) and device-to-CIE mappings, and is used as input for CMM (color management modules).

The range of colors that can be reproduced is similary limited per technology.

TODO: research use of perceptual CIE models further. Document project functions,
add CMM/calibration setup. Split those details off into color math and color
profile conventions.

## Other file formats

Currently the Chauvet palette source is 24bit values, with many swatches
directly copied from some standard X11 configuration.

TODO: describe related color palette/theme file formants


