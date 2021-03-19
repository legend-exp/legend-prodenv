#!/bin/bash

###############################################################################
# Description
###############################################################################
usage() { 
\echo >&2  "Usage: prodenv-load-sw [OPTIONS] ./path/to/config.json"
\cat >&2 <<EOF

This script starts the container of a production cycle.
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
if [ -z "$1" ]; then
   usage
fi
# Check mandatory arguments
if [ ! -f "$1" ]; then
   \echo "Error: config file not valid."
   exit 1;
fi

local VENV_BASE_DIR=`\python -c "\
import sys, json, os;
config_file = sys.argv[1];
config_file_dir = os.path.dirname(os.path.abspath(config_file));
config_dic = json.load(open(config_file));
target = config_dic['setups']['l200hades']['execenv']['envvars']['VENV_BASE_DIR'];
print(os.path.join(config_file_dir,target));
" $1`

VENV_BASE_DIR=$VENV_BASE_DIR \venv default
}

run "$@"
