"""
More or less initial ad-hox version to read RGB.txt and convert/add some
columns in different notations.
"""
import sys

from chauvettk.rgbtxt import read_rgbtxt_datalines_fl, rgbtxt_autofill


def is_greyshade(r, g, b):
    return (r == g == b)


if __name__ == '__main__':
    args = sys.argv[1:]
    if len(args) > 0:
        fn = args.pop(0)
    else:
        fn = 'rgb.txt'
    if fn == '-':
        datain = sys.stdin
    else:
        datain = open(fn, 'r')

    data = read_rgbtxt_datalines_fl(datain, keep_comments=True)
    for fields in data:
        if len(fields) and fields[0] and fields[0] == '!':
            print(fields)
            continue

        rgb_dec = fields[0]

        if not rgb_dec:
            new_fields = ('-',) + fields[1:]
            print("\t".join(new_fields))
            continue

        name = ''
        if len(fields) > 1:
            if fields[1].strip():
                name = fields[1]

        rgb_hex = None
        if len(fields) > 2 and len(fields[2]):
            rgb_hex = fields[2].strip().upper()
            if rgb_hex:
                rgb_hex_dec = (
                    int(rgb_hex[0:2], 16),
                    int(rgb_hex[2:4], 16),
                    int(rgb_hex[4:6], 16))

        cnum = -1
        if len(fields) > 3:
            if len(fields[3].strip()):
                cnum = int(fields[3])

        if rgb_dec and rgb_hex:
            for i in (0, 1, 2):
                if rgb_hex_dec[i] != rgb_dec[i]:
                    print("RGB mismatch: %s %i <> %i" % ("RGB"[i],
                                                         rgb_hex_dec[i],
                                                         rgb_dec[i]),
                          file=sys.stderr)
                    raise ValueError()

        elif not rgb_dec:
            rgb_dec = tuple(rgb_hex_dec)

        elif not rgb_hex:
            rgb_hex = "".join(
                        [hex(v)[2:].rjust(2, '0') for v in rgb_dec]
                    ).upper()

        rgb_spec = " ".join(map(str, rgb_dec))

        if is_greyshade(*rgb_dec):
            xterm = ''
            urwid = ''
        else:
            xterm = sum(map(int, [16,
                        ((rgb_dec[0]-55)/40) * 36,
                        ((rgb_dec[1]-55)/40) * 6,
                        ((rgb_dec[2]-55)/40)]))
            #if xterm != cnum:
            #    print('TODO: update cnum column from %s to %s' % (cnum, xterm))
            um = [0, 6, 8, 0xa, 0xd, 0xf]
            urwid = "".join(map(lambda v: hex(v)[2:], map(lambda i: um[int(i)], [
                        ((rgb_dec[0]-55)/40),
                        ((rgb_dec[1]-55)/40),
                        ((rgb_dec[2]-55)/40)])))

        new_fields = (
          rgb_spec,
          name,
          rgb_hex,
          #str(cnum),
          str(xterm),
          #str(urwid),
        ) + fields[4:]
        print("\t".join(new_fields))
