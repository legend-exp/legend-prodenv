# Main setup file for the test enviroment. It needs to be sourced
export TESTENV="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH="${TESTENV}/bin:$PATH"
export TESTENV_REFPROD="${TESTENV}/ref-prod"
export TESTENV_USERPROD="${TESTENV}/user-prod"

alias testenv-bash.sh="source $TESTENV/bin/testenv-load.sh"



