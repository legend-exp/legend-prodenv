#!/bin/bash

###############################################################################
# Description
###############################################################################
usage() { 
\echo >&2  "Usage: testenv-r2d [OPTIONS] ./path/to/config.json ./path/to/keylist.txt"
\cat >&2 <<EOF

This script runs the data production over the files listed in the keylist

Options:
   -m    maximum number of events to process
   -v    increased output verbosity
   -q    submit jobs with qsub

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
# Set defaults, parse options, performs checks
###############################################################################
testenv-r2d() {

# Parse options and overwrite the variable default value
while getopts "vm:" options; do
   case ${options} in
      v) VERBOSITY="-v";;
      m) MAX_EV_NUM="-m "${OPTARG};;
   esac
done
shift $((OPTIND - 1))

# Check mandatory arguments
if [ -z "$1" ] || [ -z "$2" ]; then
   usage
fi
# Check mandatory arguments
if [ ! -f "$1" ]; then
   \echo "Error: config file not valid."
   exit 1;
fi
if [ ! -f "$2" ]; then
   \echo "Error: keylist not valid."
   exit 1;
fi

# extract installation dir
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

# extract dir in which data are genrated
local RAW=`\python -c "\
import sys, json, os;
config_file = sys.argv[1];
config_file_dir = os.path.dirname(os.path.abspath(config_file));
config_dic = json.load(open(config_file));
target = config_dic['setups']['testenv']['data']['raw'];
print(os.path.join(config_file_dir,target));
" $1`

local DSP=`\python -c "\
import sys, json, os;
config_file = sys.argv[1];
config_file_dir = os.path.dirname(os.path.abspath(config_file));
config_dic = json.load(open(config_file));
target = config_dic['setups']['testenv']['data']['dsp'];
print(os.path.join(config_file_dir,target));
" $1`

local META=`\python -c "\
import sys, json, os;
config_file = sys.argv[1];
config_file_dir = os.path.dirname(os.path.abspath(config_file));
config_dic = json.load(open(config_file));
target = config_dic['setups']['testenv']['data']['meta'];
print(os.path.join(config_file_dir,target));
" $1`

local PROCESSOR_LIST=`\python -c "\
import sys, json, os;
config_file = sys.argv[1];
config_file_dir = os.path.dirname(os.path.abspath(config_file));
config_dic = json.load(open(config_file));
target = config_dic['setups']['testenv']['proc']['raw_to_dsp']['processor_list'];
print(os.path.join(sys.argv[2],target));
" $1 $META` 

echo $PROCESSOR_LIST

for i in `cat $2`; do
    pygama-run.py -i $RAW/$i -o $DSP/$i -c $PROCESSOR_LIST -s raw_to_dsp $VERBOSITY $MAX_EV_NUM
done

}

testenv-r2d "$@"

