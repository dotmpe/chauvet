if ! (return 0 2>/dev/null); then
  >&2 echo "userlocal-core: This file should be sourced, not executed directly"
  exit 1
fi

if [[ ${ENV_NAME:+set} ]]; then
  >&2 echo "userlocal-core: Already have .env imported"
  return 1
fi

# ENV_{LOCAL,NAME,PATH}

declare -ga ENV_LOCAL

: "${ENV_PATH:=.${ENV_NAME:=env}}"

usertools_localenv_load() {

  for env_file in ${ENV_PATH//:/ }; do
    if [[ ! ${env_file:+set} || ! -s "$env_file" ]]; then
      >&2 echo "Missing or empty .env file: ${env_file@Q} (ignored)"
    else
      [[ ${ENV_LOCAL[*]:+set} ]] && env_offset="${#ENV_LOCAL[*]}" || env_offset=0
      :pass "$(command grep -Po '^([A-Z_][A-Z0-9_]+)(?==)' "${env_file}")" &&
      mapfile -O $env_offset -t ENV_LOCAL <<< "$_" &&
      . "${env_file:?}" ||
        :failerr "While loading ${env_file@Q}" || return
    fi
  done; unset env_file
  [[ ${ENV_LOCAL[*]:+set} ]] ||
    :failerr "Found nothing to export for ${ENV_NAME:-env} at ${ENV_PATH}" ||
      return
}

usertools_localenv_export() {
  [[ ${ENV_LOCAL:+set} ]] || usertools_localenv_load || return
  declare -x "${ENV_LOCAL[@]}"
}

# Id: userbuild-core                             vim:set ft=bash sw=2 sts=2 et:
