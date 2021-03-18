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
   -p    custom path to user source directory. Install pygama and pyfcutils if 
         not found [default: new-production-cycle/software/src]

   -o    set github organization user code is cloned from [default: legend-exp]

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
# Main function: parse options, create dir/file structure, download pygama
###############################################################################
testenv-init() {

###############################################################################
# Set defaults, parse options, performs checks
###############################################################################

# Set defaultslocal GITHUB_ORGANIZATION="legend-exp"
local GITHUB_BRANCH="master"
local SRC_PATH=""
local PROD_ENV=${TESTENV_USERPROD}

# Parse options and overwrite the variable default value
while getopts "p:o:b:rh:" options; do
   case ${options} in
      p) SRC_PATH=${OPTARG};;
      o) GITHUB_ORGANIZATION=${OPTARG};;
      b) USER_CODETHUB_BRANCH=${OPTARG};;
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
\mkdir -p $PROD_ENV/$PRODUCTION_TAG/gen
\mkdir -p $PROD_ENV/$PRODUCTION_TAG/genpar
\mkdir -p $PROD_ENV/$PRODUCTION_TAG/meta/{daq,raw,dsp,hit,keylists}
\mkdir -p $PROD_ENV/$PRODUCTION_TAG/software/{inst,src}

# FIXME: MPIK specific path
\ln -s /lfs/l1/legend/software/singularity/legendexp_legend-base_latest_20210313112951.sif container.sif

# Create json config file
\cat > ${PROD_ENV}/${PRODUCTION_TAG}/config.json  <<EOF
{
   "setups": {
      "l200hades": {
         "data": {
            "orig": "/lfs/l1/legend/detector_char/enr/hades/char_data",
            "gen": "${PROD_ENV}/${PRODUCTION_TAG}/gen"
            "meta": "${PROD_ENV}/${PRODUCTION_TAG}/meta"
         },
         "proc": {
           "daq_to_raw": {}, 
           "raw_to_dsp": {},
           "dsp_to_hit": {} 
         }
         "prodver": "v01.00",
         "software": {
            "venv": {
               "path": "${PROD_ENV}/bin/venv",
               "name": "legend"
            },
        "src": {
          "python": "./software/src/python"
        },
        "inst":"./software/inst" 
         }
      }
   }
EOF

# Replace raw data path based on REFPROD name
TESTENV_REFPROD_BASENAME=`\basename $TESTENV_REFPROD`
\sed -i "s/TESTENV_REFPROD_BASENAME/${TESTENV_REFPROD_BASENAME}/g" ${PROD_ENV}/${PRODUCTION_TAG}/config.json

# Create json config file
\cat > ${PROD_ENV}/${PRODUCTION_TAG}/meta/dsp/processor_list.json  <<EOF
{
  "outputs": [
    "bl", "bl_sig", "trapEmax"
  ],
  "processors":{
    "bl, bl_sig":{
      "function": "mean_stdev",
      "module": "pygama.dsp.processors",
      "args" : ["waveform[0:1000]", "bl", "bl_sig"],
      "prereqs": ["waveform"],
      "unit": ["ADC", "ADC"]
    },
    "wf_blsub":{
      "function": "subtract",
      "module": "numpy",
      "args": ["waveform", "bl", "wf_blsub"],
      "prereqs": ["waveform", "bl"],
      "unit": "ADC"
    },
    "wf_pz": {
      "function": "pole_zero",
      "module": "pygama.dsp.processors",
      "args": ["wf_blsub", "db.pz.tau", "wf_pz"],
      "prereqs": ["wf_blsub"],
      "unit": "ADC",
      "defaults": { "db.pz.tau":"260*us" }
    },
    "wf_trap": {
      "function": "trap_norm",
      "module": "pygama.dsp.processors",
      "args": ["wf_pz", "8*us", "2*us", "wf_trap"],
      "prereqs": ["wf_pz"],
      "unit": "ADC"
    },
    "trapEmax": {
      "function": "amax",
      "module": "numpy",
      "args": ["wf_trap", 1, "trapEmax"],
      "kwargs": {"signature":"(n),()->()", "types":["fi->f"]},
      "unit": "ADC",
      "prereqs": ["wf_trap"]
    }
  }
}
EOF

# Install pygramma if path is empty
if [ -z "${SRC_PATH}" ]; then
   \git clone \
      git@github.com:${GITHUB_ORGANIZATION}/pygama.git \
      ${PROD_ENV}/${PRODUCTION_TAG}/software/src/python/pygama \
      --branch ${GITHUB_BRANCH}
      git@github.com:${GITHUB_ORGANIZATION}/pyfcutils.git \
      ${PROD_ENV}/${PRODUCTION_TAG}/software/src/python/pyfcutils \
      --branch ${GITHUB_BRANCH}
      git@github.com:${GITHUB_ORGANIZATION}/legend-dataflow-hades.git \
      ${PROD_ENV}/${PRODUCTION_TAG}/software/src/python/legend-dataflow-hades \
      --branch ${GITHUB_BRANCH}
fi

echo "Done."
}

testenv-init "$@"
