#!/usr/bin/env bash

compileShTpl ()
{
	false
}

writeSass () # ~
{
  local started=
  true "${namepad:=20}"
  echo "// sass-theme"
  while IFS=$'\t\n' read rgb name hex n
  do
    test -n "$(echo $rgb $name $hex $n)" || {
      echo
      continue
    }

    case "$rgb $name" in
      ( "! @"* )
        echo $rgb $name $hex $n | sed 's/\! @\(.*\): \(.*\)$/\/\/ @\1: \2/'
        continue ;;
      ( "!"* ) continue ;;
    esac

    test -n "$started" || {
      started=1
      echo ":root"
    }

    #echo "  \$$name: #$hex"
    printf '  $%-'$namepad's %s\n' "$name:" "#$hex"
  done
  echo "// Generated on $(date) from '$0 $*'"
}

test $# -gt 0 || set -- writeSass
"$@"
