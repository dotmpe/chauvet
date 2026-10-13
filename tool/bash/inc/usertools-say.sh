
:say-when() {
: param '~ <Level> <Message> ...'
: tag util
: input "${1?$(:argv-err 1 'Verbosity level')}"
: input "${2?$(:argv-err 2 'Verbal message')}"
  local min_level=${1:-2}

  (( VERBOSITY >= min_level )) || return 0
  printf '%s\n' "${*:2}" >&${USER_FD}
}

:say-dsl() {
  say.err() { :say-when 1 "$1"; }
  say.info() { :say-when 2 "$1"; }
  say.v() { :say-when 3 "$1"; }
  say.debug() { :say-when 4 "$1"; }

  # XXX: helpers for user-equiv. for log, temporary until better init
  :_debug() {
    ((QUIET)) || ! ((DEBUG)) || :say-when 4 "$1"
  }
  :_info() {
    ((QUIET)) || :say-when 2 "$@"
  }
  :_notice() {
    ((QUIET)) || :say-when 3 "$@"
  }
}

# Id: usertools-say                              vim:set ft=bash sw=2 sts=2 et:
