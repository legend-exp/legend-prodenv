#!/bin/bash

###############################################################################
# Description
###############################################################################
usage() { 
\echo >&2  "Usage: testenv-init [OPTIONS] PRODUCTION_TAG"
\cat >&2 <<EOF

This script initializes a new production cycle named PRODUCTION_TAG.
PRODUCTION_TAG is a mandatory argument and should be parsed after the options. 

Options:
   -p <path>   Set custom path to user source directory. When not specified, 
               all user software is cloned into new-production-cycle/src/python

   -o <name>   Set the name of the github organization software is cloned from
               [default: legend-exp]

   -b <name>   Set name of the branch to check out   [default: master]
               Note that all reps need to have a branch with the same name

   -c <path>   Set path to singularity container defaultp

   -r          Create a production cycle under prod-ref [default: prod-user]

EOF
exit 1;
}

###############################################################################
# Check whether the setup.sh has been already sourced
###############################################################################
if [ -z "$PRODENV_PROD_REF" ] || [ -z "$PRODENV_PROD_USER" ]; then
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

# Parse options and overwrite the variable default value
while getopts "p:o:b:rh:" options; do
   case ${options} in
      p) PATH_SRC=${OPTARG};;
      o) GITHUB_ORGANIZATION=${OPTARG};;
      b) GITHUB_BRANCH=${OPTARG};;
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
#\cp -l  $PRODENV_DEFAULT_CONTAINER $PATH_CYCLE/$PRODUCTION_TAG/venv/default/
ln -s  $PRODENV_DEFAULT_CONTAINER $PATH_CYCLE/$PRODUCTION_TAG/venv/default/
\ln -s `\basename $PRODENV_DEFAULT_CONTAINER` \
       $PATH_CYCLE/$PRODUCTION_TAG/venv/default/rootfs.sif

# FIXME:clean this
# tools: software tools
#\mkdir -p $PATH_CYCLE/$PRODUCTION_TAG/tools
#\git clone \
#   git@github.com:oschulz/singularity-venv.git \
#   $PATH_CYCLE/$PRODUCTION_TAG/tools/venv

# FIXME: clean this up
# bin: executable and scripts
#\mkdir -p $PATH_CYCLE/$PRODUCTION_TAG/bin
#\ln -s ../tools/venv/bin/venv $PATH_CYCLE/$PRODUCTION_TAG/bin/


# Create json config file
ROOTDIR=$PATH_CYCLE/$PRODUCTION_TAG
\cat > $PATH_CYCLE/$PRODUCTION_TAG/config.json  <<EOF
{
    "setups": {
        "l200hades": {
            "paths": {
                "orig": "/lfs/l1/legend/detector_char/enr/hades/char_data",
                "gen": "$ROOTDIR/gen",
                "meta": "$ROOTDIR/meta",
                "par": "$ROOTDIR/par",
                "src": {
                    "python": "$ROOTDIR/src/python"
                }
            },
            "execenv": {
                "envvars": {
                    "VENV_BASE_DIR": "$ROOTDIR/venv"
                },
                "cmd": ["$ROOTDIR/tools/venv/bin/venv", "legend"]
            }
        }
    }
} 
EOF
echo "Done."
}

run "$@"
