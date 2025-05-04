#!/usr/bin/env bash

chauvet_default_do_env ()
{
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
}

chauvet_default_do_main ()
{
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
        local fun src
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
        local name="${_%.rgb.txt}"
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
        local name="${_%.rgb.txt}" rgbtxtupdate
        rgbtxtupdate="$B/rgbtxt:update:${name:?RGB.txt filename expected}"
        redo-ifchange "@rgbtxt:update:${name}" &&
        >&2 mkdir -p "$D/chart" &&
        < "${rgbtxtupdate}" \
          OUTPUT="$D/chart/${name:?}.svg" python tool/py/cards.py &&
        < "$D/chart/${name:?}.svg" redo-stamp &&
        redo-ifchange "$D/chart/${name:?}.svg" tool/py/cards.py
      ;;

  ( @rgbtxt:data:* )
        # Grep only color data, and sed to tsv
        : "${1##*:}"
        local name="${_%.rgb.txt}" rgbtxtdata
        rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
        redo-ifchange "src/${name}.rgb.txt" &&
        grep -v '^\(!\|!.[^@].*\|\s*\)$' "${_}" |
        > "${rgbtxtdata:?}" sed "${CHAUVET_FIXRGB_SED}" &&
        < "${rgbtxtdata:?}" redo-stamp &&
        if_ok "$(wc -l "${rgbtxtdata:?}")" &&
        >&2 echo "Palette ${name}: ${_%% *} swatches" &&
        redo-ifchange "${rgbtxtdata:?}"
      ;;

  ( @rgbtxt:diff:* )
        : "${1##*:}"
        local name="${_%.rgb.txt}" rgbtxt{data,update}
        rgbtxtdata="$B/rgbtxt:data:${name:?RGB.txt filename expected}"
        rgbtxtupdate="$B/rgbtxt:update:${name}"
        redo-ifchange \
          "@rgbtxt:data:${name}" \
          "@rgbtxt:update:${name}" &&
        >&2 diff -bqr "${rgbtxtdata}" "${rgbtxtupdate}"
      ;;

  ( @rgbtxt:sass:all:* )
        : "${1##*:}"
        local name="${_%.rgb.txt}" rgbtxtsassroot
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
        local name="${_%.rgb.txt}" rgbtxt{update,sassroot}
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
        local name="${_%.rgb.txt}" rgbtxtupdate
        rgbtxtupdate="$B/rgbtxt:update:${name:?RGB.txt filename expected}"
        redo-ifchange "@rgbtxt:data:${name}" tool/py/rgbtxt.py &&
        < "${B}/rgbtxt:data:${name}" > "${rgbtxtupdate:?}" \
        	python tool/py/rgbtxt.py - &&
        < "${rgbtxtupdate:?}" redo-stamp &&
        redo-ifchange "${rgbtxtupdate:?}"
      ;;

  ( @sass:shvars:* )
        : "${1##*:}"
        local name="${_%.rgb.txt}" rgbtxtsassall sassshvars
        rgbtxtsassall="$B/rgbtxt:sass:all:${name}"
        sassshvars="$B/sass:shvars:${name}"
				redo-ifchange "@rgbtxt:sass:all:${name}" &&
        < "${rgbtxtsassall}" \
        > "${sassshvars}" \
					bash tool/bash/sass.sh readShSimpleVars
      ;;

  ( @sass:tab:* )
        : "${1##*:}"
        local name="${_%.rgb.txt}" rgbtxtsassall sasstab
        rgbtxtsassall="$B/rgbtxt:sass:all:${name}"
        sasstab="$B/sass:tab:${name}"
				redo-ifchange "@rgbtxt:sass:all:${name}" &&
        < "${rgbtxtsassall}" > "${sasstab}" \
					sass_quiet=1 bash tool/bash/sass.sh readTab
      ;;

  ( @sass:themex:* )
        : "${1##*:}"
        local name="${_%.rgb.txt}" sass{tab,themex}
        sasstab="$B/sass:tab:${name}"
        sassthemex="$B/sass:themex:${name}"
				redo-ifchange "@sass:tab:${name}" &&
        < "${sasstab}" > "${sassthemex}" bash tool/bash/sass.sh typeThemex
      ;;

    * )
        >&2 echo "! Unknown target: ${1@Q}"
        exit "${_E_nsa:-68}"
      ;;

  esac

  # End build if handler has not exit already
  exit $?
}

[[ ! ${REDO_RUNID+set} ]] || {
  chauvet_default_do_env "$@" &&
  chauvet_default_do_main "$@"
}
