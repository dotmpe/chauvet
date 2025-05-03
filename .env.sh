#!/usr/bin/env bash
export PYTHONPATH=tool/py
case "${REDO_TARGET-}" in

( all|@all|:all )
    chauvet_all_target=(
      @build:rgbtxt:Chauvet
      @build:rgbtxt:Chauvet-hsl
      @build:rgbtxt:Tango16dark
      @build:rgbtxt:Tango
      @build:rgbtxt:Grayscale23
      @build:rgbtxt:Xorg
      @build:rgbtxt:Xterm16
    )
  ;;

( @build:rgbtxt:chart:* )
    export SWATCH=180 COLS=rgbhex,hls,lab
  ;;
esac

case "${REDO_TARGET-}" in

( @build:rgbtxt:chart:Chauvet )
    export GRID=3,6
  ;;

( @build:rgbtxt:chart:Chauvet-hsl )
    export GRID=3,6
  ;;

( @build:rgbtxt:chart:Grayscale23 )
    export GRID=6,4
  ;;

( @build:rgbtxt:chart:Tango16dark )
    export GRID=8,2
  ;;

( @build:rgbtxt:chart:Tango )
    export GRID=6,5
  ;;

( @build:rgbtxt:chart:Xterm16 )
    export GRID=8,2
  ;;

( @build:rgbtxt:chart:Xorg )
    export GRID=34,22 # ~ 16:10
    #export GRID=31,24 # ~ 4:3
    export SWATCH=120 COLS=rgbhex
    #,hls,lab
  ;;

esac
