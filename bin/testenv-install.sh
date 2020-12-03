#!/bin/bash

###############################################################################
# Description
###############################################################################
usage() { 
\echo >&2  "Usage: testenv-install [OPTIONS] ./path/to/config.json"
\cat >&2 <<EOF

This script install the software in the production cycle
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
# Main function: load variables from config file and install python
###############################################################################
testenv-install() {

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

# Create the virtual env if it has not been initialized yet
if [ ! -d "$INST/venv" ]; then
   \virtualenv -p /usr/bin/python3 $INST/venv
   source $INST/venv/bin/activate
   \python -m pip install --upgrade pip
   \python -m pip install ipython numpy
fi

# Start virtual env
source $INST/venv/bin/activate
\python -m pip install -e $SRC/pygama
deactivate
# End virtual env

echo "Done."
}

testenv-install "$@"
