#!/usr/bin/env bash

if [[ ! ${REDO_RUNID+set} ]]; then
  >&2 echo "Chauvet .build-select.sh: this file should be part of a redo build"
  return 1
fi

mkdir -p "${B:?Build dir expected}" "${D:?Dist dir expected}" &&
case "${1:?}" in
( @env:* )
    redo-ifchange "tool/bash/lib/chauvettk.lib.sh"
  ;;
( * )
    redo-ifchange "@env:fun:tool/bash/lib/chauvettk.lib.sh:chauvettk_lib__load"
  ;;
esac &&

case "${1:?}" in

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

( @palettes ) # Copy palette charts
      redo-always &&
      if [[ ${PALETTE_DIR:+set} ]]; then
        # TODO: if VERBOSE/DEBUG/DIAG vflag=v and vflag=vu
        # TODO: only if INIT, mkdir; also clear dir of known files for INIT or DIAG
        >&2 mkdir -vp "${PALETTE_DIR:?}"/{Charts-{bitmap,vector},Source} &&
        >&2 rsync -azvui --exclude '*.svg' --include '*.png' "${D:?}/chart/" "${PALETTE_DIR}"/Charts-bitmap &&
        >&2 rsync -azvui --exclude '*.png' --include '*.svg' "${D:?}/chart/" "${PALETTE_DIR}"/Charts-vector &&
        >&2 rsync -azvui "./src/rgbtab/" "${PALETTE_DIR}"/Source

        exit
      else
        >&2 echo "No PALETTE_DIR setting"
        exit 1
      fi
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
      grep -v '^\([#;!]\|[#;!].[^@].*\|\s*\)$' "${_}" |
        > "${rgbtxtdata:?}" sed "${CHAUVET_FIXRGB_SED}" &&
      #chauvettk_normalize_rgbtxt_names |
      #> "${rgbtxtdata:?}" awk '!a[$1$2$3]++' &&
      < "${rgbtxtdata:?}" redo-stamp &&
      if_ok "$(grep -cv '^-' "${rgbtxtdata:?}")" &&
      >&2 echo "Palette ${name}: ${_%% *} swatches" &&
      redo-ifchange "${rgbtxtdata:?}"
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
      say.v "Updated ${rgbtxtvars@Q}"
    ;;

( @rgbtxt:vars:float:scad:* )
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxt{data,out}
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      rgbtxtout="$D/vars/$name.rgb.scad"
      :to-v mkdir -vp "$D/vars"
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
      say.v "Updated ${rgbtxtout@Q}"
    ;;

( @rgbtxt:vars:float:* )
: about 'Write as variable assignments, normalized floats, comma separated in []'
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxt{data,vars}
      rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
      rgbtxtvars="$D/vars/$name.rgb.float.tsv"
      :to-v mkdir -vp "$D/vars"
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
      say.v "Updated ${rgbtxtvars@Q}"
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
      say.v "Updated ${rgbtxtvars@Q}"
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


( @rgbtxt:sass:all:* )
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxtsassroot
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
      exit
    ;;

( @rgbtxt:sass:root:* )
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxt{update,sassroot}
      rgbtxtupdate="$B/rgbtxt:update:${name:?RGB.txt filename expected}"
      rgbtxtsassroot="$B/rgbtxt:sass:root:${name}"
      redo-ifchange \
        "@rgbtxt:update:${name}" @env:fun:tool/bash/rgb.sh:writeSass &&
      < "${rgbtxtupdate}" > "${rgbtxtsassroot}" \
      bash tool/bash/rgb.sh writeSass &&
      < "${rgbtxtsassroot}" redo-stamp
      exit
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


( @sass:shvars:* )
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxtsassall sassshvars
      rgbtxtsassall="$B/rgbtxt:sass:all:${name}"
      sassshvars="$B/sass:shvars:${name}"
      redo-ifchange "@rgbtxt:sass:all:${name}" &&
      < "${rgbtxtsassall}" \
      > "${sassshvars}" \
        bash tool/bash/sass.sh readShSimpleVars
      exit
    ;;

( @sass:tab:* )
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" rgbtxtsassall sasstab
      rgbtxtsassall="$B/rgbtxt:sass:all:${name}"
      sasstab="$B/sass:tab:${name}"
      redo-ifchange "@rgbtxt:sass:all:${name}" &&
      < "${rgbtxtsassall}" > "${sasstab}" \
        sass_quiet=1 bash tool/bash/sass.sh readTab
      exit
    ;;


( @sass:themex:* )
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" sass{tab,themex}
      sasstab="$B/sass:tab:${name}"
      sassthemex="$B/sass:themex:${name}"
      redo-ifchange "@sass:tab:${name}" &&
      < "${sasstab}" > "${sassthemex}" bash tool/bash/sass.sh typeThemex
      exit
    ;;


( @themex )
      >&2 themex Chauvet.themex &&
      < Chauvet.themex/buids/sublime/chauvet256dark.tmTheme \
        redo-stamp &&
      redo-ifchange Chauvet.themex/theme.yml
      exit
    ;;

  * ) return ${_E_next:?}
esac
