#!/bin/bash

###############################################################################
# Description
###############################################################################
usage() { 
\echo >&2  "Usage: testenv-clean.sh"
\cat >&2 <<EOF

This script unset all env variables created by the scripts of the testing env.
It should be sourced.
EOF
exit 1;
}

###############################################################################
# Unset variables
###############################################################################
unset TESTENV_REFPROD
unset TESTENV_USERPROD
unset PYTHONPATH
unset PYTHONUSERBASE

echo "Warning: umask is set to "`\umask`". Fix it by hand if needed"
echo "Warning: PYTHONPATH and PYTHONUSERBASE have been unset"
echo "Done."
