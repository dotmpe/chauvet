:cache-load () {
: param '~ <Data-file> ...'
: name User-Conf.Cache.load-file
: tag util aux cache
  (($#)) || return ${_E_MA:?}
: input "${1?$(:argv-err 1 'Data file')}"

  [[ -s "${1}" ]] &&
  \builtin . "${1}" && {
    ! ((VERBOSE)) || {
      :pass "$(du -hs "${1}")" && : "${_%%[$'\t	']*}" &&
      say.debug "Cache loaded ($_ bytes)" || :
    }
  } || say.debug "Missing or empty ${1@Q} cache (E$?, ignored)"
}

:cache-loadmaps () {
: name User-Conf.Cache.load-maps
: param '~ <Data-file> <Map-exports...>'
: about 'Helper to retrieve map arrays from Shell cache file'
: tag cache
  (($#)) || return ${_E_MA:?}
: input "${1?$(:argv-err 1 'Shell script cache file')}"
: input "${2?$(:argv-err 2 'Associative array name(s)')}"

  declare -gA "${@:2}" ||
    :failerr "Cannot declare global maps ${*@Q}" || return
  [[ -x "${1}" ]] &&
  \builtin . "${1}" && {
    ! ((VERBOSE)) || {
      # Print summary of loaded bytes/items
      :pass "$(du -hs "${1}")" && : "${_%%[$'\t	']*}" &&
      say.debug "Cache loaded ($_ bytes) for ${*:2}" || :
      local -n _ref
      for _ref in "${@:2}"; do
        [[ ! -n "${_ref[*]:+set}" ]] ||
          say.info "Found ${#_ref[@]} ${!_ref} items in cache"
      done
    }
  } || say.debug "Missing or empty ${1@Q} cache (E$?, ignored)"
}

# Id: usertools-data                             vim:set ft=bash sw=2 sts=2 et:
