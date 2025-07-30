#!/usr/bin/env bash

chauvettk_lib__load ()
{
  # reforat to space separated tuple and tab separated rest
  CHAUVET_FIXRGB_SED='s/^\s*\([0-9][0-9]*\)\s*\([0-9][0-9]*\)\s*\([0-9][0-9]*\)\s*\([^\s]*\)/\1 \2 \3	\4/g'
  # normalize name to camelcase

  export B=${B:-.chauvet/build}
  export D=${D:-.chauvet/dist}
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
