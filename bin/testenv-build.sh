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
# Actual script implemented as function to protect against users sourcing it
###############################################################################
testenv-build() {

local SRC=`\python -c "\
import sys, json, os;
config_file = sys.argv[1];
config_file_dir = os.path.dirname(os.path.abspath(config_file));
config_dic = json.load(open(config_file));
target = config_dic['setups']['testenv']['software']['src'];
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
}

testenv-build "$@"
