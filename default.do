#!/usr/bin/env bash

chauvet_default_do_env ()
{
  . "./.env.sh" &&
  redo-ifchange "./.env.sh" &&
  export B=${B:-.chauvet/build} &&
  mkdir -p "${B:?}"
}

chauvet_default_do_main ()
{
  case "${1:?}" in

  # Default build target
  ( all|@all|:all )
        redo-ifchange "${chauvet_all_target[@]}"
      ;;

  ( @build:rgbtxt:chart:* )
        : "${1##*:}"
        local name="${_%.rgb.txt}" rgbtxtupdate
        rgbtxtupdate="$B/rgbtxt:update:${name:?RGB.txt filename expected}"
        redo-ifchange "@build:rgbtxt:update:${name}" &&
        OUTPUT="${name:?}.svg" python tool/py/cards.py < "${rgbtxtupdate}" &&
        < "${name:?}.svg" redo-stamp &&
        redo-ifchange "${name:?}.svg" tool/py/cards.py
      ;;

  ( @build:rgbtxt:data:* )
        # Grep only color data, and sed to tsv
        : "${1##*:}"
        local name="${_%.rgb.txt}" rgbtxtdata
        rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
        redo-ifchange "${name}.rgb.txt" &&
        grep -v '^\(!.*\|\s*\)$' "${_}" |
        sed 's/^\s*\([0-9][0-9]*\)\s*\([0-9][0-9]*\)\s*\([0-9][0-9]*\)\s*\([^\s]*\)/\1 \2 \3	\4/g' > "${rgbtxtdata:?}" &&
        < "${rgbtxtdata:?}" redo-stamp &&
        if_ok "$(wc -l "${rgbtxtdata:?}")" &&
        >&2 echo "Palette ${name}: ${_%% *} swatches" &&
        redo-ifchange "${rgbtxtdata:?}"
      ;;

  ( @build:rgbtxt:diff:* )
        : "${1##*:}"
        local name="${_%.rgb.txt}" rgbtxt{data,update}
        rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
        rgbtxtupdate="$B/rgbtxt:update:${name}"
        redo-ifchange \
          "@build:rgbtxt:data:${name}" \
          "@build:rgbtxt:update:${name}" &&
        >&2 diff -bqr "${rgbtxtdata}" "${rgbtxtupdate}"
      ;;

  ( @build:rgbtxt:update:* )
        : "${1##*:}"
        local name="${_%.rgb.txt}" rgbtxtupdate
        rgbtxtupdate="$B/rgbtxt:update:${name:?RGB.txt filename expected}"
        redo-ifchange "@build:rgbtxt:data:${name}" tool/py/rgbtxt.py &&
        < "${B}/rgbtxt:data:${name}" > "${rgbtxtupdate:?}" python tool/py/rgbtxt.py - &&
        < "${rgbtxtupdate:?}" redo-stamp &&
        redo-ifchange "${rgbtxtupdate:?}"
      ;;

  ( @build:rgbtxt:* )
        : "${1##*:}"
        local name="${_%.rgb.txt}"
        redo-ifchange \
          "@build:rgbtxt:data:${name}" \
          "@build:rgbtxt:update:${name}" \
          "@build:rgbtxt:diff:${name}" \
          "@build:rgbtxt:chart:${name}"
      ;;

    * )
        >&2 echo "! Unknown target: $1"
        false
      ;;

  esac

  # End build if handler has not exit already
  exit $?
}

[[ ! ${REDO_RUNID+set} ]] || {
  chauvet_default_do_env "$@" &&
  chauvet_default_do_main "$@"
}
