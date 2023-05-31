# Main setup file for the production enviroment. It needs to be sourced
export PRODENV=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
export PATH="${PRODENV}/bin:${PRODENV}/tools/bin:$PATH"
export PYTHONDONTWRITEBYTECODE=1
