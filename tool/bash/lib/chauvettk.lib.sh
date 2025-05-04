#!/usr/bin/env bash

chauvettk_lib__load ()
{
  CHAUVET_FIXRGB_SED='s/^\s*\([0-9][0-9]*\)\s*\([0-9][0-9]*\)\s*\([0-9][0-9]*\)\s*\([^\s]*\)/\1 \2 \3	\4/g'

  export B=${B:-.chauvet/build}
  export D=${D:-.chauvet/dist}
}

#
