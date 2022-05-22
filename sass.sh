#!/usr/bin/env bash

ci=
s=
is=

pop_stack ()
{
  test "$ci" = "$is" && {
    s=
    is=
    ci=
  } || {
    s=${s% *}
    is=${is% *}
    ci=${is//* }
  }
}

push_stack ()
{
  test -z "$s" && s="$1" || s="$s $1"
  test -z "$is" && is=$ind || is="$is $ind"
}

ret_stack ()
{
  while test -n "$is" -a "$ci" != "$ind"
  do
    pop_stack
  done
  pop_stack
}

while IFS= read line
do

  test -n "$(echo $line)" || continue

  ind="$(echo "$line" | sed 's/^\( *\)[^ ]*$/\1/g')"
  ind=${#ind}

  case "$(echo $line)" in
    ( "// @"* )
      echo $line | sed 's/\/\/ @\(.*\): \(.*\)$/\1="\2"/'
      eval "$(echo $line | sed 's/\/\/ @\(.*\): \(.*\)$/\1="\2"/')"
      continue ;;
    ( "//"* ) continue ;;
    ( "$"* )
      eval "$(echo $line | sed 's/$\(.*\): \([0-9a-f]*\)/\1="\2"/')"
      continue ;;
    ( *": "* )
      eval "echo \"    \"$line"
      continue ;;
  esac

  case "$line" in ( *"," )
    ;; esac

  test -z "$ci" && {

    push_stack $line
    ci=$ind
  } || {

    test "$ci" = "$ind" && {
      pop_stack
      push_stack $line

    } || {

      test "${ci:-0}" -gt "$ind" && {
        ret_stack || true
        push_stack $line || true

      }
      test "${ci:-0}" -lt "$ind" && push_stack $line || true
      ci=$ind
    }
  }

  echo $s | tr -d ' '

done
