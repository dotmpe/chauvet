#!/bin/bash
#
# Copyright (c) 2026 .mpe  <me@dotmpe.com>
#
# Distributed under terms of the MIT license.
#
set -eETuo pipefail
shopt -s failglob nullglob
IFS=$' \t\n'

default_do_env() {
: env "${_E_GAE:=193}"
: env "${_E_MA:=194}"
: env "${_E_continue:=195}"
: env "${_E_next:=196}"
: env "${_E_break:=197}"
: env "${_E_retry:=198}"
  ! (($#)) || return ${_E_GAE:?}

  # XREDO_LOCAL=.local/config/build_redo.local.bash
  . "tool/bash/inc/usertools-core.sh" &&
  . "tool/bash/inc/userlocal-core.sh" &&
  . "tool/bash/inc/usertools-common.sh" &&
  . "tool/bash/inc/usertools-say.sh" &&
  . "tool/bash/inc/usertools-build.sh" &&
  . "tool/bash/lib/chauvettk.lib.sh" &&
  chauvettk_lib__load && :say-dsl && :common-dsl &&
  . "${U_S:?}/tool/local/common_env.bash" &&

  : || { local stat=$?
    >&2 "Chauvet build env load failure E$stat"
    return ${stat}
  }

  : "${BUILD_SELECT_SH:=./.build-select.sh}"

  if [[ -e .env.sh ]]; then
    \builtin . ./.env.sh ||
      _ :failerr "Env load error $? (while sourcing ${_@Q}, ignored)"
  elif [[ -e .env ]]; then
    usertools_localenv_export ||
      _ :failerr "Env error $? (while exporting .env, ignored)"
  fi
}

default_do_main() {
  declare BUILD_TARGET=${1:?}
  declare BUILD_TARGET_BASE=$2
  declare BUILD_TARGET_TMP=$3

  default_do_env ||
    :failerr "E$? $_" || return

  if [[ ! -e "${BUILD_SELECT_SH:?}" ]]; then
    echo "No custom build rules (BUILD_SELECT_SH=${BUILD_SELECT_SH@Q})" >&2
    unset BUILD_SELECT_SH
  else
    \builtin . "${BUILD_SELECT_SH:?}" && exit || {
      local st=$?
      (( st == _E_next )) || exit $st
    }
  fi

  case "${1:?}" in

# Default build target
( all|[@:]all )
      redo-ifchange @env:a:chauvet_all_target "${chauvet_all_target[@]:?}"
    ;;

( @build )
      redo-ifchange @env:a:chauvet_build_target "${chauvet_build_target[@]:?}"
    ;;

( @check )
      redo-ifchange @dist dist.sha1 &&
      if [[ ${VERBOSE:+set} ]]; then
        >&2 sha1sum -c dist.sha1 || return
      else
        >/dev/null sha1sum -c dist.sha1 || return
      fi &&
      < dist.sha1 redo-stamp
    ;;

( @dist )
      redo-ifchange @env:a:chauvet_dist_target "${chauvet_dist_target[@]:?}"
    ;;

( @dist:themex:* )
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" chauvet_dist_themex_recipe_target

      xredo_expand_printf_arr chauvet_dist_themex_recipe_target{_printf,} "$name" &&
      if [[ ! ${chauvet_dist_themex_recipe_target[*]:+set} ]]; then
        :failerr "No target group configured for recipe ${1@Q}"
        return
      fi &&
      redo-ifchange "@env:a:chauvet_dist_themex_recipe_target_printf" \
            "${chauvet_dist_themex_recipe_target[@]}"
    ;;

( @rgb16bit )
      redo-ifchange @env:a:chauvet_rgb16bit_target "${chauvet_rgb16bit_target[@]:?}"
    ;;

( @rgb16bit:* )
: about 'Default pattern recipe group for 16bit RGB palette, build all artefacts'
      : "${1##*:}"
      declare name="${_%.rgb.tsv}" chauvet_rgb16bit_recipe_target

      xredo_expand_printf_arr chauvet_rgb16bit_recipe_target{_printf,} "$name" &&
      if [[ ! ${chauvet_rgb16bit_recipe_target[*]:+set} ]]; then
        :failerr "No target group configured for recipe ${1@Q}"
        return
      fi &&
      redo-ifchange "@env:a:chauvet_rgb16bit_recipe_target_printf" \
            "${chauvet_rgb16bit_recipe_target[@]}"
    ;;

( @rgbtxt::all:* )
      : "${1##*:}"
      TODO
    ;;

  * )
      >&2 echo "! do,chauvet: Unknown target: ${1@Q}"
      exit "${_E_nsa:-68}"
    ;;


  esac

  # End build if handler has not exit already
  exit $?
}

[[ ! ${REDO_RUNID:+set} ]] || {

  : "${US_DEBUG:=${DEBUG:=0}}"

  default_do_main "$@"
}

# Id: default                                    vim:set ft=bash sw=2 sts=2 et:
