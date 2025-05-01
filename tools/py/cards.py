import drawsvg as draw
import datetime, math, os, sys


# Output size (excluding  padding)
w = os.getenv('WIDTH', 120)
h = os.getenv('HEIGHT', 90)

outname = 'chart'
outputfile = os.getenv('OUTPUT', None)
if not outputfile:
    if '--svg' in sys.argv:
        outputfile = outname+'.svg'
    else:
        outputfile = outname+'.png'

# grid here is milimeter based 1:1
scale = os.getenv('SCALE', 1)
dpi = os.getenv('DPI', 72)
label = os.getenv('LABEL', None)
if not label:
    title = os.getenv('TITLE', None)
    if not title:
        title = __file__[:-3]
    dt = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    label = title+' '+dt

datain = sys.stdin
data = []
for line in datain.readlines():
    line = line.strip()
    if not len(line) or line[0] == '!': continue
    # FIXME:
    if line[0] == '-': continue
    cols = line.split('\t')
    rgb = tuple(map(int, cols[0].split(' ')))
    data.append((rgb,)+tuple(cols[1:]))


padd = 5
d_dia = ( w+(2*padd), h+(2*padd) )
d = draw.Drawing(*d_dia)

col, row = 0, 0
swatch = 40
ws = math.floor((w-(2*margin_h))/swatch)
for cdata in data:
    x = col * swatch
    y = row * swatch
    d.append(draw.Rectangle(x, y, swatch, swatch, fill='#'+cdata[2]))
    col += 1
    if col > ws:
        col = 0
        row += 1

if '--no-scale' not in sys.argv:
    dpmm = dpi / 25.4
    d.set_pixel_scale(dpmm * scale)

if '--sheet' in sys.argv:
# Frame and title
    d.append(draw.Rectangle(padd+1, padd+1, w-(2*padd)-2, h-(2*padd)-2,
        fill_opacity=0, stroke=c_ter, stroke_width=stroke_fine))

    d.append(draw.Text(label, 3, w-padd-2, h-padd-2,
        fill=c_sec,
        text_anchor='end'))

# Padding marks in corners
    cropmark = draw.Rectangle(0, 0, padd, padd, fill=c_ter)
    d.append(draw.Use(cropmark, 0, 0))
    d.append(draw.Use(cropmark, w-padd, 0))
    d.append(draw.Use(cropmark, 0, h-padd))
    d.append(draw.Use(cropmark, w-padd, h-padd))

    if '--svg' in sys.argv:
        d.save_svg(outputfile)
    else:
        d.save_png(outputfile)
else:
    d.save_svg(outputfile)
