#!/usr/bin/env bash

case "${1:?}" in

( @env:a:* )
      : "${1#@env:a:}"
      if_ok "$(declare -p "${_:?Array variable name expected}")" &&
      <<< "${_}" redo-stamp &&
      redo-ifchange ".env.sh"
      exit
    ;;

( @env:fun:* )
      declare fun src
      : "${1#@env:fun:}"
      src=${_%:*} fun="${1##*:}"
      redo-ifchange "${src:?Expected source file path}" &&
      . "$src" &&
      if_ok "$(declare -f "${fun:?Expected function name}")" &&
      <<< "${_}" redo-stamp
      exit
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

( @palettes ) # Copy palette charts
      redo-always &&
      if [[ ${PALETTE_DIR:+set} ]]; then
        # TODO: if VERBOSE/DEBUG/DIAG vflag=v and vflag=vu
        # TODO: only if INIT, mkdir; also clear dir of known files for INIT or DIAG
        >&2 mkdir -vp "${PALETTE_DIR:?}"/{Charts-{bitmap,vector},Source} &&
        >&2 rsync -azvui --include-pattern '*.png' "${D:?}/chart/" "${PALETTE_DIR}"/Charts-bitmap &&
        >&2 rsync -azvui --include-pattern '*.svg' "${D:?}/chart/" "${PALETTE_DIR}"/Charts-vector &&
        >&2 rsync -azvui "./src/rgbtab/" "${PALETTE_DIR}"/Source || exit
      else
        >&2 echo "No PALETTE_DIR setting"
        exit 1
      fi
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

esac
