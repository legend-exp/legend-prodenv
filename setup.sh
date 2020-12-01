# Main setup file for the test enviroment. It needs to be sourced

umask og=r

export PATH=`pwd`"/bin:$PATH"
export TESTENV_REFPROD=`pwd`"/ref-prod"
export TESTENV_USERPROD=`pwd`"/user-prod"
