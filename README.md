# LEGEND Data Production Environment

This repository provides an environment to handle multiple production cycles. The enviroment includes a file system structure and a set of python scripts. The default automatic data-production system relies on snakemake and https://github.com/legend-exp/legend-dataflow-hades

## Workflow
The steps to create a new production cycle and process the data are:
* source the `setup.sh` to set the environmental variables of the testing environment
* run `prodenv-init-cycle` to initialize a new production cycle 
* customize the setting of the new production cycle by editing its `config.json` file 
* run `prodenv-install-sw` to install the software
* run `snakemake` to populate the multi-tier data structure

The typical workflow for exisitng production cycles is:
* source the production enviroment `setup.sh`
* modify the source code (`pygama`, `pyfcutils`, `legend-dataflow-hades`) 
* run `prodenv-install-sw` to reinstall the software 
* remove from the tier structure the files that need to be reprocessed
* run `snakemake` to update the multi-tier data structure

A brief description of these steps is given in the following. Run the scripts with the option `-h` for further information on the arguments and options available.

### Source the setup file of the testing enviroment
```
$ source setup.sh
```

Sourcing the `setup.sh` file in the top directory of the testing environment will:
* set environmental variables storing the path to the test environment
* add the `bin` and `tools/bin` directory to the user's PATH to make scripts and tools available from command line

### Initialize a new production cycle
```
$ prodenv-init-cycle  -h
usage: prodenv-init-cycle [-h] [-p PATH] [-o ORGANIZATION] [-b BRANCH] [-c CONTAINER] [-r] prod_tag

Initialize a new production cycle

positional arguments:
  prod_tag         name of directory in which the production cycle is created

optional arguments:
  -h, --help       show this help message and exit
  -p PATH          set path to user src directory 
                   (default: clone reps in cycle)
  -o ORGANIZATION  set name of github organization from which reps are cloned 
                   (default:legend-exp)
  -b BRANCH        set name of branch to check out 
                   (default: master)
  -c CONTAINER     set path to software container
  -r               create a production cycle under prod-ref
```

The` testenv-init.sh` script generates a new production cycle in `prodenv/prod-usr`. This includes the directory structure and a few configuration files. It will also download a fresh version of `pygama`, `pyfcutils`, and `legend-dataflow-hades` from either the legend-exp organization (default) or a fork (specified through the option `-o organization-name`). It is possible to specify which branch to checkout through the `-b branch-name` option. When the option
`-p path/to/my-src-dir` is specified, `pygama` and `pyfcutils` are not downloaded by linked to an existing src directory whose path gets stored in `config.json`. The option `-c` allows to customize the singularity container to be used for the data production.

After initialization, the production cycle structure looks like this:
```
.
├── config.json
├── dataflow
├── gen
└── genpar
└── meta
└── src
    └── python
            ├── pygama
            └── pyfcutils
└── venv
    └── default
```

Description of file system:
* each production cycle has a `./config.json` containing all configurations. This file can be edited by hand if needed.
* `./dataflow` contains the `snakemake` configuration files. This repostiory can be edited to modify the data automatic data production
* `./gen`, `./genpar`, and `./log` are automatically generated during the dataproduction
* `./src/python` contains the software used for data produciton. Users can edit this repositories and the software will be automatically installed.
* `./venv/` directory containing a link to the singularity container and the software compiled within the container


### Install the software
```
$prodenv-install-sw -h
usage: prodenv-install-sw [-h] [-r] config_file

Install user software in data production enviroment

positional arguments:
  config_file  production cycle configuration file

optional arguments:
  -h, --help   show this help message and exit
  -r           remove software directory before installing software

```

This script loads the container and install the software under `src`. For major changes in the code, the option `-r` can be used to fully re-install the code.

### Load Container
```
$ prodenv-load-sw -h
usage: prodenv-load-sw [-h] config_file

Load data production enviroment

positional arguments:
  config_file  production cycle configuration file

optional arguments:
  -h, --help   show this help message and exit 
```
It loads the container and all the software installed. Type exit to quit.

### Run Data Production
Data can be automatically produced through 
```
snakemake --snakefile path-to-dataflow-dir/Snakefile -j20 --configfile=path-to-cycle/config.json all-B00000B-co_HS5_top_dlt-tier2.gen
```

See https://github.com/legend-exp/legend-dataflow-hades for more infor


## Contacts
Contact <matteo.agostini@ucl.ac.uk> for support and report bugs
