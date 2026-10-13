:append-path () {
: name User-Script.OS.path-assert
  assert=1 :path-append "$@" || test 1 -eq $? || return $_
}

:argv-err() {
: about 'Output helper for unset/undefined argument position expressions'
: param '~ <Position> <Label> <"expected "> <"at position "> ...'
  set -- "${FUNCNAME[1]}" "$2" "${3:-expected }" "${4:-at position }" "$1"
  printf '%s: %s %s%s%i\n' "$@"
}

:common-dsl() {
  if_ok() { return; }
  _() { "$@" || :; }
  failerr() { :failerr "$@"; }
}

:funbody () {
: name User-Script.Shell.function-body
: param '<Ref-fun> [<Dest-var>] ...'
: input "${1?$(:argv-err 1 'Function name expected')}"
  (($#-1)) &&
  local -n _out=${2?$(:argv-err 2 'Output name expected')} || local _out

  :pass "$(typeset -f "$1")" || return
  : "${_#* () }"
  : "${_:4:-2}"
  _out="$_"
  if [[ ! ${_out:+set} ]]; then
    say.v "Empty function body for ${1@Q} (ignored)"
  else
    (($#>1)) || printf '%s\n' "$_out"
  fi
}

:lookup-append() {
: name User-Script.OS.lookup-append
: about "Simple PATH-var helper to append only new, unique instance"
: param "<Directory ...> [<Var=PATH>]"
: extended "Using this helps keeping PATH cleaner, but it doesnt behave like \path_append but returns false (1) if already found"
: notes TODO "Really should write sys-wordv-add or something"
: notes "This does not export the variable"
: notes "This requires the variable name, use _OS_Path_* alternatively"
: completion 'complete -A directory'
  (($#-1)) || return ${_E_MA:-194}
  local _PATHNAME=${*:$#:1}
: input ${_PATHNAME:?$(:argv-err 1 'Lookup variable')}
  local -n _PATH=$_PATHNAME
  local _arg
  for _arg in "${@:1: $#-1}"; do
: input "${_arg:?$(:unset-err _arg 'Path value'):}"
    case ":${_PATH:-:}:" in
      ( *:"${_arg}":*)
          ((${assert:-0})) || return 1
        ;;
      ( *)
          _PATH="${_PATH:+${_PATH}:}${_arg}"
        ;;
    esac
  done
}

:path-append() {
: name User-Script.OS.path-append
: about "Simple PATH helper to append only new, unique instance"
: param "<Directory ...> [<Var=PATH>]"
: extended "Using this helps keeping PATH cleaner, but it doesnt behave like \path_append but returns false (1) if already found"
: notes TODO "Really should write sys-wordv-add or something"
: notes "This does not export PATH"
: notes "This does not require explicit PATH name for single dir argument, and last argument can always be left empty for default"
: notes "Not exactly like the same implementation as shipped with Debian/Ubuntu, see -assert variant"
: completion 'complete -A directory'
  local dirc _var
  ! (($#-1)) && dirc=1 || dirc=$#-1 _var=${*: $#:1}
  :lookup-append "${@:1: $dirc}" "${_var:-PATH}"
}

:to-v() {
: about 'Put output on USER output (regardless of verbosity)'
: param '~ <...>'
: tag dev
  "$@" >&${USER_FD}
}

:unset-err() {
: about 'Output helper for unset/undefined name expressions'
: param '~ <Symbol> <Label> <"expected "> <"at name "> ...'
  set -- "${FUNCNAME[1]}" "$2" "${3:-expected }" "${4:-at name }" "$1"
  printf '%s: %s %s%s%s\n' "$@"
}

# Id: usertools-common                           vim:set ft=bash sw=2 sts=2 et:
