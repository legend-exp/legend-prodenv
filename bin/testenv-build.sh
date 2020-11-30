#!/bin/bash

###############################################################################
# Description
###############################################################################

usage() { 
\echo >&2  "Usage: testenv-build [OPTIONS] ./path/to/config.json"
\cat >&2 <<EOF

This script install the software in the production cycle

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
# Actual script implemented as function to protect against users sourcing it
###############################################################################
testenv-build() {

# Check mandatory arguments
if [ ! -f "$1" ]; then
   usage
fi

local SRC=`\python -c "\
import sys, json, os;
config_file = sys.argv[1];
config_file_dir = os.path.dirname(os.path.abspath(config_file));
config_dic = json.load(open(config_file));
target = config_dic['setups']['testenv']['software']['src']['python'];
print(os.path.join(config_file_dir,target));
" $1`

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
\python -m pip install -e $SRC/pygama

echo "Done."
}

testenv-build "$@"
