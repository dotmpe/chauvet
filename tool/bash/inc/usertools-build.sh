
xredo_expand_printf_arr() {
  local -n _exp_printf_inp=${1:?}
  local -n _exp_printf_out=${2:?}
  shift 2
  #local printf_args=( "$@" )
  for _exp_printf in "${_exp_printf_inp[@]}"; do
    if_ok "$(printf "$_exp_printf" "$@")" &&
    _exp_printf_out+=( "$_" ) || return
  done
}

# Id: usertools-build                            vim:set ft=bash sw=2 sts=2 et:
