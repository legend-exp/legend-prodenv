#!/bin/sh

declare -r SCRIPT_NAME=$(readlink -f ${BASH_SOURCE[0]})
PRODENV=$(cd -P -- "$(dirname -- $SCRIPT_NAME)" && pwd -P)
# custom prodenv software gets precedence
PATH="${PRODENV}/bin:${PRODENV}/tools/bin:$PATH"
PYTHONDONTWRITEBYTECODE=1

export PRODENV PATH PYTHONDONTWRITEBYTECODE
