eval "echo \"
version: $doc__version
description: $doc__description
author: $doc__author
colorSpaceName: $doc__colorSpaceName

themes:
  - name: $doc__name
    uuid: $doc__UUID
    baseColor: $doc__baseColor
    colors:
$(for c in ${!color__*}
  do
    v=${!c}
    echo "       ${c:7}: $v"
  done | sort)

    settings:
$(for c in ${!tm__settings__*}
  do
    v=${!c}
    echo "       ${c:14}: $v"
  done | sort)


rules:
$(for c in ${!tm__rule__*}
  do
    v=${!c}
    p=${c//*__}
    scope=${c:10}
    scope=${scope//__/.}
    scope=${scope//_/-}
    cat <<EOM
  - name:
    scope: $scope
    $p: $v
EOM
  done)
\""
# ex:ft=bash:
