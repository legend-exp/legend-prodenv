#!/bin/bash

###############################################################################
# Description
###############################################################################
usage() { 
\echo >&2  "Usage: prodenv-install-sw [OPTIONS] ./path/to/config.json"
\cat >&2 <<EOF

This script install the software in the production cycle
EOF
exit 1;
}

###############################################################################
# Check whether the setup.sh has been already sourced
###############################################################################
if [ -z "$PRODENV" ]; then
   \echo "Error: source setup.sh before continuing.";
   exit 1;
fi

###############################################################################
# Main function: load variables from config file and install python
###############################################################################
run() {

# Check mandatory arguments
if [ ! -f "$1" ]; then
   usage
fi
# Check mandatory arguments
if [ ! -f "$1" ]; then
   \echo "Error: config file not valid."
   exit 1;
fi

local SRC=`\python -c "\
import sys, json, os;
config_file = sys.argv[1];
config_file_dir = os.path.dirname(os.path.abspath(config_file));
config_dic = json.load(open(config_file));
target = config_dic['setups']['l200hades']['paths']['src']['python'];
print(os.path.join(config_file_dir,target));
" $1`

local VENV_BASE_DIR=`\python -c "\
import sys, json, os;
config_file = sys.argv[1];
config_file_dir = os.path.dirname(os.path.abspath(config_file));
config_dic = json.load(open(config_file));
target = config_dic['setups']['l200hades']['execenv']['envvars']['VENV_BASE_DIR'];
print(os.path.join(config_file_dir,target));
" $1`

\rm -rvf $VENV_BASE_DIR/default/user/.local;
\venv default python3 -m pip install -e $SRC/pyfcutils
\venv default python3 -m pip ninstall -e $SRC/pygama

echo "Done."
}

run "$@"
