import sys

if __name__ == '__main__':

    #fl = open('rgb.txt','a+')
    fl = open('rgb.txt','r')
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

      print("\t".join([
            " ".join(map(str,rgb_dec)),
            name,
            "".join(map(lambda v: hex(v)[2:].ljust(2,'0'),rgb_hex)),
            str(cnum)
          ]))
#
