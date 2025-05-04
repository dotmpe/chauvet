#!/usr/bin/env bash

compileShTpl ()
{
	false
}

# Read 16bit RGB TSV, output SASS :root rule with colorname definitions.
# Converts comments with meta attributes to CSS line commments.
writeSass () # ~
{
  local started= rgb name hex rest
  true "${namepad:=20}"
  echo "// sass-theme"
  while IFS=$'\t\n' read -r rgb name hex rest
  do
    [ "${rgb:--}" != - ] || {
      echo
      continue
    }

    case "$rgb $name" in
      ( "! @"* )
        echo $rgb $name $hex $rest | sed 's/\! @\(.*\): \(.*\)$/\/\/ @\1: \2/'
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
  echo
  echo "// Generated on $(date) from '$0 $*' ex:ft=sass:"
}

case "${0##*/}" in
( rgb.sh )
	test $# -gt 0 || set -- writeSass
	"$@"
;;
esac
