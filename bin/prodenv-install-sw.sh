#!/bin/bash

###############################################################################
# Description
###############################################################################
usage() { 
\echo >&2  "Usage: prodenv-install-sw [OPTIONS] ./path/to/config.json"
\cat >&2 <<EOF

This script install the software in the production cycle

Options:
   -r  remove installation dir before reinstalling software 

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

local RM_INST_DIR=false
# Parse options and overwrite the variable default value
while getopts "rh:" options; do
   case ${options} in
      r) RM_INST_DIR=true;;
      h) usage;;
   esac
done
shift $((OPTIND - 1))

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

if [ "$RM_INST_DIR" = true ]; then
   \rm -rvf $VENV_BASE_DIR/default/user/.local;
fi
VENV_BASE_DIR=$VENV_BASE_DIR \venv default python3 -m pip install -e $SRC/pyfcutils
VENV_BASE_DIR=$VENV_BASE_DIR \venv default python3 -m pip install -e $SRC/pygama

echo "Done."
}

run "$@"
