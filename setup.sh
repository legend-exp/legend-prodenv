# Main setup file for the production enviroment. It needs to be sourced
export PRODENV="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH="${PRODENV}/bin:${PRODENV}/tools/bin:$PATH"
export PYTHONDONTWRITEBYTECODE=1
