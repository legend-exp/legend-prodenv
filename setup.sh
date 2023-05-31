#!/bin/sh

PRODENV=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
PATH="${PRODENV}/bin:${PRODENV}/tools/bin:$PATH"
PYTHONDONTWRITEBYTECODE=1

export PRODENV PATH PYTHONDONTWRITEBYTECODE
