#!/usr/bin/env bash

# Build/project toolkit for Chauvet

chauvettk_lib__load() {
  # reforat to space separated tuple and tab separated rest
  CHAUVET_FIXRGB_SED='s/^\s*\([0-9][0-9]*\)\s*\([0-9][0-9]*\)\s*\([0-9][0-9]*\)\s*\([^\s]*\)/\1 \2 \3	\4/g'
  # normalize name to camelcase

  export B=${B:-.local/build/chauvet}
  export D=${D:-.local/dist/chauvet}

  . "tool/bash/inc/usertools-core.sh" &&
  . "tool/bash/inc/userlocal-core.sh" &&
  . "tool/bash/inc/usertools-common.sh" &&
  . "tool/bash/inc/usertools-say.sh" &&
  . "tool/bash/inc/usertools-build.sh"
}

chauvettk_lib__init() {
  :say-dsl && :common-dsl &&
  # TODO: replace chauvetk/user-tools env init with callback
  . "${U_S:?}/tool/local/common_env.bash"
}


chauvettk_normalize_rgbtxt_names ()
{
  local r g b name word
  while read -r r g b name
  do
    printf '%i %i %i ' $r $g $b
    for word in $name
    do
      : "${word^}"
      printf '%s' "$_"
    done
    printf '\n'
  done
}

#
