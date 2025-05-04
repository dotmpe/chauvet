import re
import sys


CHAUVET_RGBTXT_COLS = [
    'rgb_16bit', 'x11_name', 'rgb_hex', 'xterm', 'urwid', 'tags'
]


wsc_rex = re.compile(r'\W+')


def rgbtxt_autofill():
    pass


def read_rgbtxt_datalines_fl(datain, keep_comments=False):
    """
    Read using plain Python, returns row-tuples.
    """
    palette = []
    ln = 0
    for line in datain.readlines():
        ln += 1
        if not len(line.strip()) or line[0] == '!':
            if line[0] == '!' and keep_comments:
                palette.append(line.strip())
                continue
        cols = line.rstrip().split('\t')
        if len(cols) > 2 and not cols[1]:
            del cols[1]
        # XXX: skipping 'empty' colors, ie. rgb '- - -' as well.
        if line[0] == '-' or not len(cols[0]):
            rgb = None
        else:
            rgb_spec = wsc_rex.sub(' ', cols[0].strip())
            try:
                rgb = tuple(map(int, rgb_spec.split(' ')))
            except ValueError as e:
                print("Error on line %i" % ln, file=sys.stderr)
                raise e
        palette.append((rgb,)+tuple(cols[1:]))
    return palette


def read_rgbtxt_tsv_dict_fl(datain):
    """
    Read using csv package, returns row-dicts using CHAUVET_RGBTXT_COLS for
    key names.
    """
    import csv
    palette = []
    reader = csv.DictReader(datain, fieldnames=CHAUVET_RGBTXT_COLS,
                            delimiter='\t', skipinitialspace=True)
    for row in reader:
        if len(row['rgb_16bit']) and row['rgb_16bit'][0] in ('!', '#'):
            continue
        rgb_spec = row['rgb_16bit']
        if rgb_spec[0] == '-':
            row['rgb_16bit'] = None
        else:
            rgb_spec = wsc_rex.sub(' ', rgb_spec.strip())
            try:
                row['rgb_16bit'] = tuple(map(int, rgb_spec.split(' ')))
            except ValueError as e:
                raise e
        palette.append(row)
    return palette
