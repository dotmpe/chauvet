#!/usr/bin/env bash

# Chauvet main build file: see .env.sh for config

set -eETuo pipefail

#[[ ! ${REDO_RUNID+set} ]]

. "tool/bash/lib/chauvettk.lib.sh" &&
chauvettk_lib__load &&

# All the build target config
. "./.env.sh" &&

mkdir -p "${B:?Build dir expected}" "${D:?Dist dir expected}" &&
case "${1:?}" in
( @env:* )
    redo-ifchange "tool/bash/lib/chauvettk.lib.sh"
  ;;
( * )
    redo-ifchange "@env:fun:tool/bash/lib/chauvettk.lib.sh:chauvettk_lib__load"
  ;;
esac &&

# Development target and recipe handlers
. "./.build-select.sh" &&

case "${1:?}" in

# Default build target
( all|[@:]all )
      redo-ifchange @env:a:chauvet_all_target "${chauvet_all_target[@]}"
    ;;

( @build )
      redo-ifchange @env:a:chauvet_build_target "${chauvet_build_target[@]}"
    ;;

( @check )
      redo-ifchange @dist dist.sha1 &&
      >&2 sha1sum -c dist.sha1 &&
      < dist.sha1 redo-stamp
    ;;

( @dist )
      redo-ifchange @env:a:chauvet_dist_target "${chauvet_dist_target[@]}"
    ;;

( @dist:themex:* )
      TODO
    ;;

( @rgb16bit )
      redo-ifchange @env:a:chauvet_rgb16bit_target "${chauvet_rgb16bit_target[@]}"
    ;;

( @rgb16bit:* )
: about 'Default target group for 16bit RGB palette, build all artefacts'
      : "${1##*:}"
      declare name="${_%.rgb.tsv}"
      redo-ifchange \
        "@rgbtxt:data:${name}" \
        "@rgbtxt:update:${name}" \
        "@rgbtxt:diff:${name}" \
        "@rgbtxt:sass:root:${name}" \
        "@rgbtxt:sass:all:${name}" \
        "@rgbtxt:chart:${name}" \
        "@sass:shvars:${name}" \
        "@sass:tab:${name}" \
        "@sass:themex:${name}"
    ;;

( @rgbtxt:chart:* )
: about 'Build tabular swatch grid (set GRID to customize)'
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxtupdate
      rgbtxtupdate="$B/rgbtxt:update:${name:?RGB.txt filename expected}"
      redo-ifchange "@rgbtxt:update:${name}" &&
      >&2 mkdir -p "$D/chart" &&
      < "${rgbtxtupdate}" \
        OUTPUT="$D/chart/${name:?}.svg" python tool/py/cards.py &&
      < "$D/chart/${name:?}.svg" redo-stamp &&
      convert "$D/chart/${name:?}.svg" "$D/chart/${name:?}.png" &&
      redo-ifchange "$D/chart/${name:?}.svg" tool/py/cards.py
    ;;

( @rgbtxt:data:* )
: about 'Grep-out comment lines, and sed to TSV so we can sort/compare on data'
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxtdata
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      redo-ifchange "src/rgbtab/${name}.rgb.tsv" &&
      grep -v '^\(!\|!.[^@].*\|\s*\)$' "${_}" |
        > "${rgbtxtdata:?}" sed "${CHAUVET_FIXRGB_SED}" &&
      #chauvettk_normalize_rgbtxt_names |
      #> "${rgbtxtdata:?}" awk '!a[$1$2$3]++' &&
      < "${rgbtxtdata:?}" redo-stamp &&
      if_ok "$(grep -cv '^-' "${rgbtxtdata:?}")" &&
      >&2 echo "Palette ${name}: ${_%% *} swatches" &&
      redo-ifchange "${rgbtxtdata:?}"
    ;;

( @rgbtxt:vars:float:scad:* )
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxt{data,out}
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      rgbtxtout="$D/vars/$name.rgb.scad"
      >&2 mkdir -vp "$D/vars"
      redo-ifchange "src/rgbtab/${name}.rgb.tsv" &&
      < "$rgbtxtdata" > "$rgbtxtout" awk '
        /[0-9]+ [0-9]+ [0-9]+	[[:alnum:]]+	[0-9A-F]+/ {
          match($0, /([0-9]+) ([0-9]+) ([0-9]+)	([[:alnum:]]+)	([0-9A-F]+).*/, m)
          print m[4] " = [" m[1]/255 ", " m[2]/255 ", " m[3]/255 "];"
          next
        }
      ' &&
      redo-ifchange \
        "@rgbtxt:data:${name}" \
        "@rgbtxt:update:${name}" &&
      >&2 echo "Updated ${rgbtxtout@Q}"
    ;;
( @rgbtxt:vars:float:* )
      # Write as variable assignments, normalized floats, comma separated in []
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxt{data,vars}
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      rgbtxtvars="$D/vars/$name.rgb.float.tsv"
      >&2 mkdir -vp "$D/vars"
      redo-ifchange "src/rgbtab/${name}.rgb.tsv" &&
      < "$rgbtxtdata" > "$rgbtxtvars" awk '
        /[0-9]+ [0-9]+ [0-9]+	[[:alnum:]]+	[0-9A-F]+/ {
          match($0, /([0-9]+) ([0-9]+) ([0-9]+)	([[:alnum:]]+)	([0-9A-F]+).*/, m)
          print m[4] "\t" m[1]/255 "\t" m[2]/255 "\t" m[3]/255
          next
        }
      ' &&
      redo-ifchange \
        "@rgbtxt:data:${name}" \
        "@rgbtxt:update:${name}" &&
      >&2 echo "Updated ${rgbtxtvars@Q}"
    ;;
( @rgbtxt:vars:16bit:py:* )
      # Write as variable assignments, decimal int pairs, comma separated in ()
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxt{data,vars}
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      rgbtxtvars="$D/vars/$name.rgb.py"
      >&2 mkdir -vp "$D/vars"
      redo-ifchange "src/rgbtab/${name}.rgb.tsv" &&
      < "$rgbtxtdata" > "$rgbtxtvars" awk '
        /[0-9]+ [0-9]+ [0-9]+	[[:alnum:]]+	[0-9A-F]+/ {
          match($0, /([0-9]+) ([0-9]+) ([0-9]+)	([[:alnum:]]+)	([0-9A-F]+).*/, m)
          print m[4] " = (" m[1] ", " m[2] ", " m[3] ");"
          next
        }
      ' &&
      redo-ifchange \
        "@rgbtxt:data:${name}" \
        "@rgbtxt:update:${name}" &&
      >&2 echo "Updated ${rgbtxtvars@Q}"
    ;;

( @rgbtxt:vars:hex:* )
: about 'Write as variable assignments, in 6 hexadecimals, no prefix'

      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxt{data,vars}
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      rgbtxtvars="$D/vars/$name.rgb.names.list"
      >&2 mkdir -vp "$D/vars"
      redo-ifchange "src/rgbtab/${name}.rgb.tsv" &&
      < "$rgbtxtdata" > "$rgbtxtvars" gawk '
        /[0-9]+ [0-9]+ [0-9]+	[[:alnum:]]+	[0-9A-F]+/ {
          match($0, /([0-9]+) ([0-9]+) ([0-9]+)	([[:alnum:]]+)	([0-9A-F]+).*/, m)
          print m[4] "=" m[5]
          next
        }
      ' &&
      redo-ifchange \
        "@rgbtxt:data:${name}" \
        "@rgbtxt:update:${name}" &&
      >&2 echo "Updated ${rgbtxtvars@Q}"
    ;;

( @rgbtxt:diff:* )
: about 'Check that data lines are in sync (have HEX, XTERM columns) without automatic overwrite'

      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxt{data,update}
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      rgbtxtupdate="$B/rgbtxt:update:${name}"
      redo-ifchange \
        "@rgbtxt:data:${name}" \
        "@rgbtxt:update:${name}" &&
      >&2 diff -bqr "${rgbtxtdata}" "${rgbtxtupdate}"
    ;;

( @rgbtxt::all:* )
      : "${1##*:}"
      TODO
    ;;

( @rgbtxt:update:* )
: about 'Read ...'

      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxtupdate
      rgbtxtupdate="$B/rgbtxt:update:${name:?RGB.txt filename expected}"
      redo-ifchange "@rgbtxt:data:${name}" tool/py/rgbtxt.py &&
      < "${B}/rgbtxt:data:${name}" > "${rgbtxtupdate:?}" \
        python tool/py/rgbtxt.py - &&
      < "${rgbtxtupdate:?}" redo-stamp &&
      redo-ifchange "${rgbtxtupdate:?}"
    ;;

  * )
      >&2 echo "! do,chauvet: Unknown target: ${1@Q}"
      exit "${_E_nsa:-68}"
    ;;

esac

# End build if handler has not exit already
exit $?
