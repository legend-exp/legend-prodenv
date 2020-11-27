# Main setup file for the test enviroment, needs to be sourced

umask og=r

testenv_env=`pwd`
export PATH="$testenv_env/bin:$PATH"

export TESTENV_REFPROD="$testenv_env/ref-prod"
export TESTENV_REFPROD="$testenv_env/user-prod"
