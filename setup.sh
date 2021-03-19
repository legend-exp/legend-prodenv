# Main setup file for the production enviroment. It needs to be sourced
export PRODENV="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PRODENV_PROD_USER="${PRODENV}/prod-user"
export PRODENV_PROD_REF="${PRODENV}/prod-ref"
export PRODENV_DEFAULT_CONTAINER='/lfs/l1/legend/software/singularity/legendexp_legend-base_latest_20210313112951.sif'
export PATH="${PRODENV}/bin:${PRODENV}/tools/bin:$PATH"
