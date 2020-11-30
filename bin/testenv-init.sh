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
   -p    custom path to pygama source directory. Install pygama if not found
         [default: new-production-cycle/software/src]

   -o    set github organization pygama is cloned from [default: legend-exp]

   -b    set which branch to checkout [default: master]

   -r    create a reference production cycle. By default the production cycle
         is created in the user space
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
testenv-init() {

###############################################################################
# Set defaults, parse options, performs checks
###############################################################################

# Set defaults
local PYGAMA_ORGANIZATION="legend-exp"
local PYGAMA_BRANCH="master"
local PYGAMA_PATH=""
local PROD_ENV=${TESTENV_USERPROD}

# Parse options and overwrite the variable default value
while getopts "p:u:b:rh:" options; do
   case ${options} in
      p) PYGAMA_PATH=${OPTARG};;
      u) PYGAMA_ORGANIZATION=${OPTARG};;
      b) PYGAMA_BRANCH=${OPTARG};;
      r) PROD_ENV=$TESTENV_REFPROD;;
      h) usage;;
   esac
done
shift $((OPTIND - 1))

# Get and test production tag
PRODUCTION_TAG="$1"
if [ -z "${PRODUCTION_TAG}" ]; then
   usage
fi

# Check whether the production cycle already exists
if [ -d "$PROD_ENV/$PRODUCTION_TAG" ]; then
   \echo "Error: a data production cycle with the same name already exists"
   exit 1;
fi

###############################################################################
# Build new production enviroment
###############################################################################

# Create file system
\mkdir -p $PROD_ENV/$PRODUCTION_TAG/software/{inst,src}
\mkdir -p $PROD_ENV/$PRODUCTION_TAG/data/{gen,meta}

# Create json config file
\cat > ${PROD_ENV}/${PRODUCTION_TAG}/config.json  <<EOF
{
  "setups": {
    "testenv": {
      "software": {
        "src": {
          "python": "./software/src/python"
        },
        "inst":"./software/inst" 
      },
      "data": {
        "raw":  "./../../TESTENV_REFPROD_BASENAME/master/data/raw",
        "gen":  "./data/gen",
        "meta": "./data/meta"
      }
    }
  }
} 
EOF

# Replace raw data path based on REFPROD name
# FIXME: this is pretty ugly hack
TESTENV_REFPROD_BASENAME=`\basename $TESTENV_REFPROD`
\sed -i "s/TESTENV_REFPROD_BASENAME/${TESTENV_REFPROD_BASENAME}/g" ${PROD_ENV}/${PRODUCTION_TAG}/config.json

# Install pygramma if path is empty
if [ -z "${PYGAMA_PATH}" ]; then
   \git clone \
      git@github.com:${PYGAMA_ORGANIZATION}/pygama.git \
      ${PROD_ENV}/${PRODUCTION_TAG}/software/src/python/pygama \
      --branch ${PYGAMA_BRANCH}
fi

echo "Done."
}

testenv-init "$@"
