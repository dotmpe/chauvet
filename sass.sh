#!/usr/bin/env bash

### Simple SASS subset reader in shell, and handlers for expanding templates


## Utils and global vars for parser

ci=
s=
is=
I=

pop_stack ()
{
  debug "pops"
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
  debug "pushs"
  case "$1" in ( *"," )
      push_group $1
      return
    ;; esac
  test -z "$s" && s="$1" || s="$s $1"
  test -z "$is" && is=$ind || is="$is $ind"
}

ret_stack ()
{
  debug "rets"
  while test -n "$is" -a "$ci" != "$ind"
  do
    pop_stack
  done
  pop_stack
}

push_group ()
{
  test -z "$g" && g="$1" || g="$g $1"
  #test -z "$is" && is=$ind || is="$is $ind"
}

finish_groups ()
{
  test -z "$g" && return
  push_group "${s//* }"
  pop_stack
}

print_tab ()
{
  local k="$1"; shift
  test "${TAB_EVALC:-0}" -eq 1 && {
    eval "echo \"$(printf '%s' $k | tr -d ',#') $*\""
  } || {
    test "${2:0:1}" = "$" &&
      echo "$(printf '%s' $k | tr -d ',#') $1 \$color__${2:1}" ||
      echo "$(printf '%s' $k | tr -d ',#') $*"
  }
}

debug ()
{
  test ${sass_quiet:-0} = 1 ||
  	echo "$1$l ind='$ind' ci='$ci' s='$s' is='$is' g='$g' I='$I'" >&2
}


## Main handlers


# Like evalHereShTpl but this template type can embed its own here-doc
# expression as well.
evalEchoShTpl () # ~ # Expand text with embedded shell scripts, including here-docs
{
  eval "echo \"$(readTpl "$@")\""
}

# Take any string with shell variable rerences (and any embedded shell
# expression) and execute them.
evalHereShTpl () # ~ # Expand text with embedded shell expressions
{
	eval "cat <<EOM
$(readTpl "$@")
EOM"
}

# Define variables for all color, doc and other properies, app-settings
evalProperties ()
{
	eval "$(readShSimpleVars | grepShProperties)"
}

#shellcheck disable=2015
evalHere () # ~ [<Sh-Tpl> [<Tab-File>]] # The simplest way to use a tab file as template
{
	test $# -le 2 || return 64

  # Get a copy of stdin to run the two pipelines if no args for files are given
	test \( -z "${1:-}" -o ! -e "${1:-}" \) -a -z "${2:-}" && {
		set -- "${1:-}" /tmp/sass-tab-$RANDOM.tmp
		cat > "$2"
	}

	# First evaluate properties, either from stdin, or a file/our copy of stdin
	test -e "$1" -a $# -eq 1 && {
		# Template provided, can read tab from stdin
		evalProperties || return
	} || {
		# No template and/or tab provided, read tab from file
		evalProperties < "${2:?}" || return
	}

	test -e "$1" && {
	  # Generate output from given template file
		eval"${tpl_type:-Echo}"ShTpl < "$1" || return

	} || {
	  # Some hardcoded, 'named' formats for output
		case "${1:-sh}" in
			( sh ) readShSimpleVars < "$2" | eval"${tpl_type:-Echo}"ShTpl ;;
			( tab ) eval"${tpl_type:-Echo}"ShTpl < "$2" ;;

			( * ) echo "No such tab conversion format '${1:-}'" >&2; return 63 ;;
		esac
	}
}

# XXX: no sure if it really needs a distinction between property and rule declarations
# see themex.tpl
grepShProperties ()
{
	#grep -v '[[:alnum:]]__[[:alnum:]]'
	#grep '^\(doc\|color\)__
	grep -v '^_'
}

readTab () # ~ # Read SASS to an intermediate, line-based triples format 'tab'
{
  l=0
  while IFS= read line
  do
    l=$(( $l + 1 ))

    test -n "$(echo $line)" || continue
    debug "$l: '$line'"

    ind="$(echo "$line" | sed 's/^\( *\)[^ ]*.*$/\1/g')"
    ind=${#ind}

    debug "a"

    case "$(echo $line)" in

      ( "// @"* )
        echo $line | sed 's/^\/\/ @/doc /'
        continue ;;
      ( "//"* ) continue ;;

      ( "$"* )
        test "${TAB_EVALC:-0}" -eq 1 && {
          eval "$(echo $line | sed 's/$\(.*\): \([0-9a-f]*\)/\1="\2"/')"
        } || {
          echo $line | sed 's/$\(.*\): \([0-9a-f]*\)/color \1 \2/'
        }
        continue ;;

      ( *": "* )
        line=$(echo "$line" | cut -c$(( $ind + 1 ))-)
        test -n "$g" && {
          I=${is//* }
          finish_groups
          for G in $g
          do
            print_tab "$s $G" $line
          done

          debug "G"
        } || {
          print_tab "$s" $line
        }
        continue ;;

    esac

    test -z "$I" -o "${I:-0}" -le "${ci:-0}" || { I=; g=; }

    test -z "$ci" && {

      push_stack $line
      ci=$ind
    } || {

      test "$ci" = "$ind" && {
      # FIXME: does it really mean to use $1 here?
        case "$1" in ( *"," )
            push_stack $line ;;
          ( * )
            pop_stack
            push_stack $line
          ;; esac

      } || {

        test "${ci:-0}" -gt "$ind" && {
          ret_stack || true
          push_stack $line || true
        } || {
          test "${ci:-0}" -lt "$ind" && {
            push_stack $line || true
          }
        }
        ci=$ind
      }
    }
  done
}

# Read text to use as template from template file, which includes prologue and
# epilogue lines. With those extra lines, syntax recognition and highlighting
# in editors can and should work normally.
#
# By default 1 leading and 2 trailing lines are removed from the template,
# allowing for one modeline at the end without that being part of the template
# text.
#
# Within the modeline, sh:tpl:<start-line>:<trim-lines>: can set alternative
# cut values if desired.
# Values 1 and 0 would span the entire file. Values 2 and 2 (the default) skip
# one line (start at line 2), and trims 2 at the end.
readTpl () # [tpl] ~ [<Script-Tpl>]
{
	test $# -le 3 || return 64
	test $# -eq 1 && {
		local mspec

		# Parse start-line and strip-last-line settings from mode-line
		mspec=$(grep -Po '^ *(#|\/\/|\/\*|;|"|\!).* \Ksh:tpl:[^ ]*' "${1:?}") && {
		  set -- "${1:-}" \
					"$(echo "$mspec" | cut -d ':' -f 3)" \
					"$(echo "$mspec" | cut -d ':' -f 4)"
		}
	}

	head -n -"${2:-2}" "${1:--}" | tail -n +"${3:-2}"
}

readShSimpleVars () # ~ # Handler to read tab and produce shell variable declarations
{
	#shellcheck disable=2162
  while read key prop value
  do
    echo -n "${key}__${prop}" | tr -d ':' | sed -e 's/\./__/g' -e 's/-/_/g'
    echo "=\"$value\""
  done
}

typeTpl () # [tab] ~ <Sh-Tpl> [<Tpl-Type>]
{
  test -s "${1:?}" || return
  evalProperties && eval"${2:-${tpl_type:-Echo}}"ShTpl "$1"
}

typeThemex () # ~
{
	typeTpl "tools/sh/echo-e/themex.yaml.tpl" Echo
}

test $# -gt 0 || set -- readTab
"$@"
