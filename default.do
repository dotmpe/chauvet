#!/usr/bin/env bash

# Chauvet main build file: see .env.sh for config

#[[ ! ${REDO_RUNID+set} ]]

. "tool/bash/lib/chauvettk.lib.sh" &&
chauvettk_lib__load &&
. "./.env.sh" &&
mkdir -p "${B:?Build dir expected}" "${D:?Dist dir expected}" &&
case "${1:?}" in
( @env:* )
    redo-ifchange "tool/bash/lib/chauvettk.lib.sh"
  ;;
( * )
    redo-ifchange "@env:fun:tool/bash/lib/chauvettk.lib.sh:chauvettk_lib__load"
  ;;
esac

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
    ;;

( @env:a:* )
      : "${1#@env:a:}"
      if_ok "$(declare -p "${_:?Array variable name expected}")" &&
      <<< "${_}" redo-stamp &&
      redo-ifchange ".env.sh"
    ;;

( @env:fun:* )
      declare fun src
      : "${1#@env:fun:}"
      src=${_%:*} fun="${1##*:}"
      redo-ifchange "${src:?Expected source file path}" &&
      . "$src" &&
      if_ok "$(declare -f "${fun:?Expected function name}")" &&
      <<< "${_}" redo-stamp
    ;;

( @rgb16bit )
      redo-ifchange @env:a:chauvet_rgb16bit_target "${chauvet_rgb16bit_target[@]}"
    ;;

( @rgb16bit:* )
      : "${1##*:}"
      declare name="${_%.rgb.txt}"
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
      : "${1##*:}"
      declare name="${_%.rgb.txt}" rgbtxtupdate
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
      # Grep-out comment lines, and sed to TSV
      : "${1##*:}"
      declare name="${_%.rgb.txt}" rgbtxtdata
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      redo-ifchange "src/${name}.rgb.txt" &&
      grep -v '^\(!\|!.[^@].*\|\s*\)$' "${_}" |
        > "${rgbtxtdata:?}" sed "${CHAUVET_FIXRGB_SED}" &&
      #chauvettk_normalize_rgbtxt_names |
      #> "${rgbtxtdata:?}" awk '!a[$1$2$3]++' &&
      < "${rgbtxtdata:?}" redo-stamp &&
      if_ok "$(wc -l "${rgbtxtdata:?}")" &&
      >&2 echo "Palette ${name}: ${_%% *} swatches" &&
      redo-ifchange "${rgbtxtdata:?}"
    ;;

# some generic variable formats, should be easy enough to convert for
# specific language notations
( @rgbtxt:vars:float:* )
      # Write as variable assignments, normalized floats, comma separated in []
      : "${1##*:}"
      declare name="${_%.rgb.txt}" rgbtxt{data,vars}
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      rgbtxtvars="$D/vars/$name.rgb.float.tsv"
      >&2 mkdir -vp "$D/vars"
      redo-ifchange "src/${name}.rgb.txt" &&
      < "$rgbtxtdata" > "$rgbtxtvars" awk '
        /[0-9]+ [0-9]+ [0-9]+	[[:alnum:]]+	[0-9A-F]+	[0-9]+/ {
          match($0, /([0-9]+) ([0-9]+) ([0-9]+)	([[:alnum:]]+)	([0-9A-F]+)	([0-9]+)/, m)
          print m[4] "\t" m[1]/255 "\t" m[2]/255 "\t" m[3]/255
          next
        }
      ' &&
      redo-ifchange \
        "@rgbtxt:data:${name}" \
        "@rgbtxt:update:${name}" &&
      >&2 echo "Updated ${rgbtxtvars@Q}"
    ;;
( @rgbtxt:vars:float:scad:* )
      : "${1##*:}"
      declare name="${_%.rgb.txt}" rgbtxt{data,out}
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      rgbtxtout="$D/vars/$name.rgb.scad"
      >&2 mkdir -vp "$D/vars"
      redo-ifchange "src/${name}.rgb.txt" &&
      < "$rgbtxtdata" > "$rgbtxtvars" awk '
        /[0-9]+ [0-9]+ [0-9]+	[[:alnum:]]+	[0-9A-F]+	[0-9]+/ {
          match($0, /([0-9]+) ([0-9]+) ([0-9]+)	([[:alnum:]]+)	([0-9A-F]+)	([0-9]+)/, m)
          print m[4] " = [" m[1]/255 ", " m[2]/255 ", " m[3]/255 "];"
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
      declare name="${_%.rgb.txt}" rgbtxt{data,vars}
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      rgbtxtvars="$D/vars/$name.rgb.py"
      >&2 mkdir -vp "$D/vars"
      redo-ifchange "src/${name}.rgb.txt" &&
      < "$rgbtxtdata" > "$rgbtxtvars" awk '
        /[0-9]+ [0-9]+ [0-9]+	[[:alnum:]]+	[0-9A-F]+	[0-9]+/ {
          match($0, /([0-9]+) ([0-9]+) ([0-9]+)	([[:alnum:]]+)	([0-9A-F]+)	([0-9]+)/, m)
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
      # Write as variable assignments, in 6 hexadecimals, no prefix
      : "${1##*:}"
      declare name="${_%.rgb.txt}" rgbtxt{data,vars}
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      rgbtxtvars="$D/vars/$name.rgbtxt.vars"
      >&2 mkdir -vp "$D/vars"
      redo-ifchange "src/${name}.rgb.txt" &&
      < "$rgbtxtdata" > "$rgbtxtvars" gawk '
        /[0-9]+ [0-9]+ [0-9]+	[[:alnum:]]+	[0-9A-F]+	[0-9]+/ {
          match($0, /([0-9]+) ([0-9]+) ([0-9]+)	([[:alnum:]]+)	([0-9A-F]+)	([0-9]+)/, m)
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
      # Check that data lines are in sync (have HEX, XTERM columns)
      # without automatic overwrite
      : "${1##*:}"
      declare name="${_%.rgb.txt}" rgbtxt{data,update}
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      rgbtxtupdate="$B/rgbtxt:update:${name}"
      redo-ifchange \
        "@rgbtxt:data:${name}" \
        "@rgbtxt:update:${name}" &&
      >&2 diff -bqr "${rgbtxtdata}" "${rgbtxtupdate}"
    ;;

( @rgbtxt::all:* )
      : "${1##*:}"
    ;;

( @rgbtxt:sass:all:* )
      : "${1##*:}"
      declare name="${_%.rgb.txt}" rgbtxtsassroot
      rgbtxtsassroot="$B/rgbtxt:sass:root:${name}"
      rgbtxtsassall="$B/rgbtxt:sass:all:${name}"
      redo-ifchange "@rgbtxt:sass:root:${name}" rules/*.sass &&
      {
        cat "${rgbtxtsassroot}" &&
        for ruleset in rules/*.sass
        do
          echo "// Source: $ruleset"
          cat "${ruleset}"
        done &&
        echo "// ${name}.sass ex:ft=sass:"
      } > "${rgbtxtsassall}" &&
      < "${rgbtxtsassall}" redo-stamp
    ;;

( @rgbtxt:sass:root:* )
      : "${1##*:}"
      declare name="${_%.rgb.txt}" rgbtxt{update,sassroot}
      rgbtxtupdate="$B/rgbtxt:update:${name:?RGB.txt filename expected}"
      rgbtxtsassroot="$B/rgbtxt:sass:root:${name}"
      redo-ifchange \
        "@rgbtxt:update:${name}" @env:fun:tool/bash/rgb.sh:writeSass &&
      < "${rgbtxtupdate}" > "${rgbtxtsassroot}" \
      bash tool/bash/rgb.sh writeSass &&
      < "${rgbtxtsassroot}" redo-stamp
    ;;

( @rgbtxt:update:* )
      : "${1##*:}"
      declare name="${_%.rgb.txt}" rgbtxtupdate
      rgbtxtupdate="$B/rgbtxt:update:${name:?RGB.txt filename expected}"
      redo-ifchange "@rgbtxt:data:${name}" tool/py/rgbtxt.py &&
      < "${B}/rgbtxt:data:${name}" > "${rgbtxtupdate:?}" \
        python tool/py/rgbtxt.py - &&
      < "${rgbtxtupdate:?}" redo-stamp &&
      redo-ifchange "${rgbtxtupdate:?}"
    ;;

( @sass:shvars:* )
      : "${1##*:}"
      declare name="${_%.rgb.txt}" rgbtxtsassall sassshvars
      rgbtxtsassall="$B/rgbtxt:sass:all:${name}"
      sassshvars="$B/sass:shvars:${name}"
      redo-ifchange "@rgbtxt:sass:all:${name}" &&
      < "${rgbtxtsassall}" \
      > "${sassshvars}" \
        bash tool/bash/sass.sh readShSimpleVars
    ;;

( @sass:tab:* )
      : "${1##*:}"
      declare name="${_%.rgb.txt}" rgbtxtsassall sasstab
      rgbtxtsassall="$B/rgbtxt:sass:all:${name}"
      sasstab="$B/sass:tab:${name}"
      redo-ifchange "@rgbtxt:sass:all:${name}" &&
      < "${rgbtxtsassall}" > "${sasstab}" \
        sass_quiet=1 bash tool/bash/sass.sh readTab
    ;;

( @sass:themex:* )
      : "${1##*:}"
      declare name="${_%.rgb.txt}" sass{tab,themex}
      sasstab="$B/sass:tab:${name}"
      sassthemex="$B/sass:themex:${name}"
      redo-ifchange "@sass:tab:${name}" &&
      < "${sasstab}" > "${sassthemex}" bash tool/bash/sass.sh typeThemex
    ;;

( @palettes ) # Copy palette charts
      redo-always &&
      >&2 mkdir -vp ~/Documents/Dev/Palettes &&
      >&2 rsync -avzui "${D:?}/chart/" \
        ~/Documents/Dev/Palettes &&
      >&2 rsync -avzui "./src/" \
        ~/Documents/Dev/Palettes
    ;;

( @themex )
      >&2 themex Chauvet.themex &&
      < Chauvet.themex/buids/sublime/chauvet256dark.tmTheme \
        redo-stamp &&
      redo-ifchange Chauvet.themex/theme.yml
    ;;

  * )
      >&2 echo "! do,chauvet: Unknown target: ${1@Q}"
      exit "${_E_nsa:-68}"
    ;;

esac

# End build if handler has not exit already
exit $?
