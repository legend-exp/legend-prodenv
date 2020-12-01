#!/bin/bash

###############################################################################
# Description
###############################################################################
usage() { 
\echo >&2  "Usage: testenv-bash [OPTIONS] ./path/to/config.json"
\cat >&2 <<EOF

This script starts a bash with the python enviromental variables set to target
the specified production cycle.

Options:
   -?    ????
EOF
exit 1;
}

###############################################################################
# Check whether the setup.sh has been already sourced
###############################################################################
if [ -z "$TESTENV_REFPROD" ] || [ -z "$TESTENV_USERPROD" ]; then
   \echo "Error: source setup.sh before continuing.";
   exit 1;
fi

###############################################################################
# Main function: extract variables from config file and start a bash
###############################################################################
testenv-bash() {

# Check mandatory arguments
if [ -z "$1" ]; then
   usage
fi
# Check mandatory arguments
if [ ! -f "$1" ]; then
   \echo "Error: config file not valid."
   exit 1;
fi

local INST=`\python -c "\
import sys, json, os;
config_file = sys.argv[1];
config_file_dir = os.path.dirname(os.path.abspath(config_file));
config_dic = json.load(open(config_file));
target = config_dic['setups']['testenv']['software']['inst'];
print(os.path.join(config_file_dir,target));
" $1`

export PYTHONPATH=$INST
export PYTHONUSERBASE=$INST
export PS1='\[\033[01;31m\]testenv \[\033[01;34m\]\w\$ \[\033[00m\]'
\bash  -norc -noprofile

echo "Exiting test mode of the testenv."
}

testenv-bash "$@"
