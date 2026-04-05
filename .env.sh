#!/usr/bin/env bash

# NOTE: .env.sh not auto-added as prerequisite for current target, so that
# targets can fine-tune their parameterized triggers more precisely.

set -eETuo pipefail

export CHAUVET_VER=0.0.1-dev
export PYTHONPATH=tool/py

if_ok () { return; } # pass back last status
declare -fx if_ok

chauvet_all_target=(
  @build
  @check
)
chauvet_build_target=(
  @rgb16bit
)
chauvet_dist_target=(
  @rgbtxt:{chart,vars:{float{,:scad},16bit:py,hex}}:BunsenLabs-boron
  @rgbtxt:{chart,vars:{float{,:scad},16bit:py,hex}}:BunsenLabs-boron-byhex # Ordered by brightness
  @rgbtxt:{chart,vars:{float{,:scad},16bit:py,hex}}:Chauvet
  @rgbtxt:{chart,vars:{float{,:scad},16bit:py,hex}}:Chauvet-hsl
  @rgbtxt:{chart,vars:{float{,:scad},16bit:py,hex}}:Tango16dark
  @rgbtxt:{chart,vars:{float{,:scad},16bit:py,hex}}:Tango
  @rgbtxt:{chart,vars:{float{,:scad},16bit:py,hex}}:Grayscale23
  @rgbtxt:{chart,vars:{float{,:scad},16bit:py,hex}}:Xorg
  @rgbtxt:{chart,vars:{float{,:scad},16bit:py,hex}}:Xterm16
  @palettes
)
chauvet_rgb16bit_target=(
  @rgb16bit:BunsenLabs-boron
  @rgb16bit:Chauvet
  @rgb16bit:Chauvet-hsl
  @rgb16bit:Tango16dark
  @rgb16bit:Tango
  @rgb16bit:Grayscale23
  @rgb16bit:Xorg
  @rgb16bit:Xterm16
)

case "${REDO_TARGET-}" in

( all|[@:]all )
  ;;

( @rgbtxt:chart:* )
    export SWATCH=180 COLS=rgbhex,hls,lab \
      LABEL_FMT="Palette {outname} ({count} swatches) - v${CHAUVET_VER}"
  ;;

esac

case "${REDO_TARGET-}" in

( @rgbtxt:chart:BunsenLabs-boron )
    export GRID=9,2
  ;;

( @rgbtxt:chart:BunsenLabs-boron* )
    export GRID=3,6
  ;;

( @rgbtxt:chart:Chauvet )
    export GRID=3,6
  ;;

( @rgbtxt:chart:Chauvet-hsl )
    export GRID=3,6
  ;;

( @rgbtxt:chart:Grayscale23 )
    export GRID=6,4
  ;;

( @rgbtxt:chart:Tango16dark )
    export GRID=8,2
  ;;

( @rgbtxt:chart:Tango )
    export GRID=6,5
  ;;

( @rgbtxt:chart:Xterm16 )
    export GRID=8,2
  ;;

( @rgbtxt:chart:Xorg )
    export GRID=20,38 #
    export SWATCH=120 COLS=rgbhex
    #,hls,lab
  ;;

esac
