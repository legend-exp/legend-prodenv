# Main setup file for the production enviroment. It needs to be sourced
export PRODENV="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH="${PRODENV}/bin:${PRODENV}/tools/bin:$PATH"

# site specific paths
export PRODENV_DEFAULT_CONTAINER='/lfs/l1/legend/software/singularity/legendexp_legend-base_latest_20210313112951.sif'
export PRODENV_DEFAULT_ORIG='/lfs/l1/legend/detector_char/enr/hades/char_data'

