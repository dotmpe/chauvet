# Only supports one type of cards, a simple row-before-cols flow.

import svgwrite
import datetime
import math
import os
import sys
from colorsys import rgb_to_hls
from chauvettk.color import rgb_norm, rgb_to_lab
from chauvettk.rgbtxt import read_rgbtxt_tsv_dict_fl

# Output size (excluding padding)

title_h = 28
cols, rows = map(int, os.getenv('GRID', '4,6').split(','))
swatch = int(os.getenv('SWATCH', 120))
w = int(os.getenv('WIDTH', cols * swatch))
h = int(os.getenv('HEIGHT', title_h + (rows * swatch)))

row_height = swatch

padd = int(os.getenv('PAGE_PADDING', 5))
swatch_padding = 8
num_padding = 4
num_col_w = 36
pt12_h = 15
pt14_h = 22
name_font = 'Liberation Sans Narrow Bold Condensed'
num_font = 'Liberation Mono Bold'
name_attr = dict(font_size='12', font_family=name_font, opacity="0.7")
num1_attr = dict(font_size='15', font_family=num_font, opacity="0.3")
num2_attr = dict(font_size='12', font_family=num_font, opacity="0.2")
title_attr = dict(font_size='18', font_family=name_font)

numcols = os.getenv('COLS', 'rgbhex').split(',')
draw_16bit_col = '16bit' in numcols
draw_rgbhex_col = 'rgbhex' in numcols
draw_hls_col = 'hls' in numcols
draw_lab_col = 'lab' in numcols

outputfile = os.getenv('OUTPUT', None)
if not outputfile:
    outname = 'chart'
    outputfile = outname+'.svg'
else:
    outname = outputfile.split('.')[0]

datain = sys.stdin
palette = read_rgbtxt_tsv_dict_fl(datain)
count = len(palette)
label = os.getenv('LABEL', None)
if not label:
    title = os.getenv('TITLE', f"Palette {outname} ({count} swatches)")
    dt = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    label = title+' '+dt

dim_w, dim_h = w+(2*padd), h+(2*padd)

dwg = svgwrite.Drawing(outputfile, size=('%ipx' % dim_w, '%ipx' % dim_h),
                       profile='full')
dwg.add(dwg.rect((0, 0), (dim_w, dim_h), fill='#f0f0f0'))  # Background

dwg.add(dwg.text(label, insert=(padd, padd+20), **title_attr))

col, row = 0, 0
for color in palette:
    x = padd + (col * swatch)
    y = padd + title_h + (row * row_height)

    if color['rgb_16bit']:
        rgb = rgb_norm(color['rgb_16bit'])
        hls = rgb_to_hls(*rgb)
        lab = rgb_to_lab(rgb)

        #if hls[1] > 0.38:
        if lab.lab_l > 40:
            # light background
            fg = 'black'
        else:
            # dark background
            fg = 'white'

        for d in name_attr, num1_attr, num2_attr:
            d['fill'] = fg
        name_attr['fill'] = fg
        num1_attr['fill'] = fg
        num2_attr['fill'] = fg

        # Draw swatch
        dwg.add(dwg.rect((x, y), (swatch, swatch), fill='#'+color['rgb_hex']))
        x += swatch_padding
        y += swatch_padding + pt12_h

        dwg.add(dwg.text(f"{color['x11_name']}", insert=(x, y), **name_attr))

        x += num_padding
        y += num_padding + pt14_h

        if draw_16bit_col:
            dwg.add(dwg.text(f"{color['rgb_16bit'][0]}", insert=(x, y), **num1_attr))
            y += pt14_h + num_padding
            dwg.add(dwg.text(f"{color['rgb_16bit'][1]}", insert=(x, y), **num1_attr))
            y += pt14_h + num_padding
            dwg.add(dwg.text(f"{color['rgb_16bit'][2]}", insert=(x, y), **num1_attr))
            y -= 2*(pt14_h + num_padding)
            x += num_col_w

        if draw_rgbhex_col:
            dwg.add(dwg.text(f"{color['rgb_hex'][0:2]}", insert=(x, y), **num1_attr))
            y += pt14_h + num_padding
            dwg.add(dwg.text(f"{color['rgb_hex'][2:4]}", insert=(x, y), **num1_attr))
            y += pt14_h + num_padding
            dwg.add(dwg.text(f"{color['rgb_hex'][4:6]}", insert=(x, y), **num1_attr))
            y -= 2*(pt14_h + num_padding)
            x += num_col_w

        if draw_hls_col:
            dwg.add(dwg.text(f"{hls[0]:.2f}", insert=(x, y), **num2_attr))
            y += pt14_h + num_padding
            dwg.add(dwg.text(f"{hls[1]:.2f}", insert=(x, y), **num2_attr))
            y += pt14_h + num_padding
            dwg.add(dwg.text(f"{hls[2]:.2f}", insert=(x, y), **num2_attr))
            y -= 2*(pt14_h + num_padding)
            x += num_col_w

        if draw_lab_col:
            dwg.add(dwg.text(f"{lab.lab_l:.2f}", insert=(x, y), **num2_attr))
            y += pt14_h + num_padding
            dwg.add(dwg.text(f"{lab.lab_a:.2f}", insert=(x, y), **num2_attr))
            y += pt14_h + num_padding
            dwg.add(dwg.text(f"{lab.lab_b:.2f}", insert=(x, y), **num2_attr))

    else:
        # Add blank or empty swatch
        pass

    col += 1
    if col == cols:
        col = 0
        row += 1

if row > rows:
    print("Overflow (%i rows, %i too many)" % (row, row - rows))

dwg.save()
