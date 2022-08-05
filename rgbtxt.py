import sys

def is_greyshade (r, g, b):
    return (r == g == b)

if __name__ == '__main__':
    args = sys.argv[1:]
    if len(args) > 0:
        fn = args.pop(0)
    else:
        fn = 'rgb.txt'

    fl = open(fn,'r')
    lines = fl.readlines()

    for line in lines:
      if not line.strip() or line.strip().startswith('!'):
          continue

      fields = line[:-1].split('\t')

      name = ''
      if len(fields) > 1:
          if fields[1].strip():
              name = fields[1]

      rgb_hex = ()
      if len(fields) > 2:
          if fields[2].strip():
              rgb_hex = (
                  int(fields[2][0:2],16),
                  int(fields[2][2:4],16),
                  int(fields[2][4:6],16) )
          else:
              rgb_hex = ( '-', '-', '-' )

      cnum = -1
      if len(fields) > 2:
          if fields[3].strip():
              cnum = int(fields[3])

      rgb_dec = fields[0].split(' ')
      for i, v in enumerate(rgb_dec):
          if v == '-':
              rgb_dec[i] = rgb_hex[i]
          elif rgb_hex[i] == '-':
              rgb_hex[i] = rgb_dec[i]
          else:
              rgb_dec[i] = int(v)
              if rgb_hex[i] != rgb_dec[i]:
                  print("sRGB mismatch for %r:%s: %s vs %s" % ( name, "RGB"[i],
                      rgb_dec[i], rgb_hex[i] ),
                          file=sys.stderr)

      if is_greyshade(*rgb_dec):
          xterm = ( '' )
      else:
          xterm = sum(map(int,[ 16,
                      ((rgb_dec[0]-55)/40) * 36,
                      ((rgb_dec[1]-55)/40) * 6,
                      ((rgb_dec[2]-55)/40) ]))
          if xterm != cnum:
              print('TODO: update cnum column from %s to %s' % (cnum, xterm))

      if is_greyshade(*rgb_dec):
          urwid = ( '' )
      else:
          # XXX:
          um = [0,6,8,0xa,0xd,0xf]
          urwid = "".join(map(lambda v:hex(v)[2:],map(lambda i: um[int(i)],[
                      ((rgb_dec[0]-55)/40),
                      ((rgb_dec[1]-55)/40),
                      ((rgb_dec[2]-55)/40) ])))


      print("\t".join([
            " ".join(map(str,rgb_dec)),
            name,
            "".join(map(lambda v: hex(v)[2:].ljust(2,'0'),rgb_hex)),
            str(cnum),
            str(urwid),
            str(xterm),

          ]))
#
