#!/bin/bash

###############################################################################
# Description
###############################################################################

usage() { 
\echo >&2  "Usage: testenv-clean.sh"
\cat >&2 <<EOF

This script unset all env variables created by the scripts of the testing env
EOF
exit 1;
}

###############################################################################
# Set defaults, parse options, performs checks
###############################################################################

unset TESTENV_REFPROD
unset TESTENV_USERPROD

echo "Warning: umask is set to "`\umask`". Fix it by hand if needed"
echo "Done."
