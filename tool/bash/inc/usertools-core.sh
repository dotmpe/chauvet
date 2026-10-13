:pass() { return; }
:ignore() { "$@" || :; }
:status() {
  local -i stat=${1:-$?}
  ((stat)) || stat=1
  return ${stat}
}
:failerr() {
  local -i stat=${2:-$?}
  ((stat)) || stat=1
  >&2 echo "$1"
  return ${stat}
}
declare -xf :{ignore,pass,status,failerr}
# Id: usertools-core                             vim:set ft=bash sw=2 sts=2 et:
