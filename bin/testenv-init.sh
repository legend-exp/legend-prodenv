#!/bin/bash

# Description
usage() { 
\echo >&2  "Usage: testenv-init [OPTIONS] PRODUCTION_TAG"
\cat >&2 <<EOF

This script initializes a new production cycle named username-PRODUCTION_TAG.
PRODUCTION_TAG is a mandatory argument and should be parsed after the options. 

Options:
   -p    set custom path to pygamma source directory. If not specificied, 
         pygamma is downloaded and stored in the production cycle structure

   -u    set the url from which to clone pygamma. By default it is 
         git@github.com:legend-exp/pygama.git  

   -b    set which branch to checkout. The default is the master

   -r    create a reference production cycle. By default a user production cycle
         is created
EOF
exit 1;
}

# Check that setup.sh has been already sourced
if [ -z "$TESTENV_REFPROD" ] || [ -z "$TESTENV_USERPROD" ]; then
   \echo "Error: source setup.sh before continuing.";
   exit 1;
fi

# Parse options
while getopts "p:u:b:rh:" options; do
   case ${options} in
      p) PYGAMMASRC=${OPTARG};;
      u) PYGAMMAURL=${OPTARG};;
      b) PYGAMMABRC=${OPTARG};;
      r) PROD_ENV=$TESTENV_REFPROD;;
      h) usage;;
   esac
done
shift $((OPTIND - 1))


# Set user prod env unless -r option is used
if [ -z "${PROD_ENV}" ]; then
    PROD_ENV=$TESTENV_USERPROD
fi

# Get and test production tag
PRODUCTION_TAG="$1"
if [ -z "${PRODUCTION_TAG}" ]; then
    usage
fi

# check that the production cycle does not exist
if [ -d "$PROD_ENV/$PRODUCTION_TAG/" ]; then
   \echo "Error: a data production cycle with the same name already exists"
   exit 1;
fi

# Create file system
mkdir -p $PROD_ENV/$PRODUCTION_TAG/software/{inst,src}
mkdir -p $PROD_ENV/$PRODUCTION_TAG/data/{gen,meta}

# Create json config file
\cat > ${PROD_ENV}/${PRODUCTION_TAG}/dataflow-config.json  <<EOF
{
  "setups": {
    "routine-dev": {
      "software": {
        "src": "\$_/software/src",
        "inst":"\$_/software/inst" 
      },
      "data": {
        "raw": "\$_/../../TESTENV_REFPROD_BASENAME/master/data/raw",
        "gen": "\$_/data/gen",
        "meta": "\$_/data/meta"
      }
    }
  }
} 
EOF

# Replace (FIXME: Oli, perhaps you find a way to do this in a nicer way)
TESTENV_REFPROD_BASENAME=`\basename $TESTENV_REFPROD`
sed -i "s/TESTENV_REFPROD_BASENAME/${TESTENV_REFPROD_BASENAME}/g" ${PROD_ENV}/${PRODUCTION_TAG}/dataflow-config.json

# Install pygramma if path is empty
if [ -z "${PYGAMMASRC}" ]; then
   # Set default url if empty
   if [ -z "${PYGAMMAURL}" ]; then
      PYGAMMAURL="git@github.com:legend-exp/pygama.git"
   fi
   # Set default branch if empty
   if [ -z "${PYGAMMABRC}" ]; then
      PYGAMMABRC="master"
   fi
   git clone ${PYGAMMAURL} ${PROD_ENV}/${PRODUCTION_TAG}/software/src/pygamma --branch ${PYGAMMABRC}
fi

echo "Done."
