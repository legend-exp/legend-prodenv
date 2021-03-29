#!/bin/bash

###############################################################################
# Description
###############################################################################
usage() { 
\echo >&2  "Usage: prodenv-init-cycle [OPTIONS] PRODUCTION_TAG"
\cat >&2 <<EOF

This script initializes a new production cycle named PRODUCTION_TAG.
PRODUCTION_TAG is a mandatory argument and should be parsed after the options. 

Options:
   -p <path>   Set custom path to user src directory. When not specified, 
               all user software is cloned from github
               [default path: new-production-cycle/src/python]

   -o <name>   Set the name of the github organization software is cloned from.
               Can be used to clone the user's forks 
               [default organization: $GITHUB_ORGANIZATION]

   -b <name>   Set name of the branch to check out
               Note that all reps need to have a branch with the same name
               [default name: $GITHUB_BRANCH]

   -c <path>   Set path to singularity container
               [default path: $PRODENV_DEFAULT_CONTAINER]

   -r          Create a production cycle under prod-ref
               [default: prod-user]

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
# Main function: parse options, create dir/file structure, download pygama
###############################################################################
run() {

###############################################################################
# Set defaults, parse options, performs checks
###############################################################################

# Set defaults
local GITHUB_ORGANIZATION="legend-exp"
local GITHUB_BRANCH="master"
local PATH_SRC=""
local PATH_CYCLE=$PRODENV_PROD_USER
local PATH_CONTAINER=$PRODENV_DEFAULT_CONTAINER

# Parse options and overwrite the variable default value
while getopts "p:o:b:rh" options; do
   case ${options} in
      p) PATH_SRC=${OPTARG};;
      o) GITHUB_ORGANIZATION=${OPTARG};;
      b) GITHUB_BRANCH=${OPTARG};;
      c) PATH_CONTAINER=${OPTARG};;
      r) PATH_CYCLE=$PRODENV_PROD_REF;;
      h) usage;;
   esac
done
shift $((OPTIND - 1))

# Get and test production tag
PRODUCTION_TAG="$1"
if [ -z "$PRODUCTION_TAG" ]; then
   usage
fi

# Check whether the production cycle already exists
if [ -d "$PATH_CYCLE/$PRODUCTION_TAG" ]; then
   \echo "Error: a data production cycle with the same name already exists"
   exit 1;
fi

###############################################################################
# Build new production enviroment
###############################################################################

# Create production cycle structure and populate it
# gen & genpar: generated data
\mkdir -p $PATH_CYCLE/$PRODUCTION_TAG/{gen,genpar}

# meta: metadata, soon a github package
\mkdir -p $PATH_CYCLE/$PRODUCTION_TAG/meta

# dataflow: dir containing snakemake configs
\git clone \
   git@github.com:legend-exp/legend-dataflow-hades.git  \
   $PATH_CYCLE/$PRODUCTION_TAG/dataflow

# src: user software
\mkdir -p $PATH_CYCLE/$PRODUCTION_TAG/src/python

if [ -z "$PATH_SRC" ]; then
   PATH_SRC="./src/python"
   \git clone \
      git@github.com:$GITHUB_ORGANIZATION/pygama.git \
      $PATH_CYCLE/$PRODUCTION_TAG/src/python/pygama \
      --branch $GITHUB_BRANCH
   \git clone \
      git@github.com:$GITHUB_ORGANIZATION/pyfcutils.git \
      $PATH_CYCLE/$PRODUCTION_TAG/src/python/pyfcutils \
      --branch $GITHUB_BRANCH
fi

# venv: venv local files
\mkdir -p $PATH_CYCLE/$PRODUCTION_TAG/venv/default/user
#FIXME
#\cp -l  $PATH_CONTAINER $PATH_CYCLE/$PRODUCTION_TAG/venv/default/
\ln -s  $PATH_CONTAINER $PATH_CYCLE/$PRODUCTION_TAG/venv/default/
\ln -s `\basename $PATH_CONTAINER` $PATH_CYCLE/$PRODUCTION_TAG/venv/default/rootfs.sif

# Create json config file
\cat > $PATH_CYCLE/$PRODUCTION_TAG/config.json  <<EOF
{
    "setups": {
        "l200hades": {
            "paths": {
                "orig": "$PRODENV_DEFAULT_ORIG",
                "gen": "\$_/gen",
                "meta": "\$_/meta",
                "par": "\$_/par",
                "src": {
                    "python": "$PATH_SRC"
                }
            },
            "execenv": {
                "legend": {
                    "env": {
                        "VENV_BASE_DIR": "\$_/venv"
                    },
                    "exec": ["$PRODENV/tools/bin/venv", "default"]
                }
            }  
        }
    }
} 
EOF

# Create json config file
\cat > $PATH_CYCLE/$PRODUCTION_TAG/meta/config_dsp.json  <<EOF
{
   "outputs": [ "bl", "bl_sig"],
   "processors":{
      "bl, bl_sig":{
         "function": "mean_stdev",
         "module": "pygama.dsp.processors",
         "args" : ["waveform", "bl", "bl_sig"],
         "prereqs": ["waveform"],
         "unit": ["ADC", "ADC"]
      }
   }
}
EOF
echo "Done."
}

run "$@"
