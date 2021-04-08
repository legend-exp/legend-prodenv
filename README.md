# LEGEND Data Production Environment

Data production environment to handle multiple production cycles. It provides a file system structure and a set of python scripts. Within each production cycle, data can be automatically generated using snakemake and https://github.com/legend-exp/legend-dataflow-hades

## Workflow
Creation of a new production cycle:
* source `setup.sh` to set some environmental variables
* run `prodenv-init-cycle` to initialize a new production cycle
* customize the `config.json` file in the production cycle
* check-out specific version of `pygama`, `pyfcutils`, `legend-dataflow-hades`, `legend-metadata`
* run `prodenv-install-sw` to install the software in `src`
* run `snakemake` to populate the multi-tier data structure

Workflow for existing production cycles:
* source `setup.sh` to set some environmental variables
* customize `pygama`, `pyfcutils`, `legend-dataflow-hades`, `legend-metadata`
* run `prodenv-install-sw` to reinstall the software 
* remove all files in `gen/` and `genpar/` that need to be reprocessed
* run `snakemake` to update the multi-tier data structure

### Source the setup file of the production  environment
```
$ source setup.sh
```

Sourcing the `setup.sh` file located at the top level of the production environment. Sourcing the file will:
* set data production environmental variables (the name of all variables start with PRODENV)
* add `./bin/` and `./tools/bin/` to PATH, making scripts and tools available from command line

The content of the source file can also be copied to the users's baschrc file. 

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

The only mandatory option of the script is `prod_tag`, i.e. the name of the production cycle. The scripts 
generates a file-system structure under `./prod-usr/prod_tag/` and, by default, it clones:
* `legend-dataflow-hades` under `./prod-usr/prod_tag/dataflow`
* `pygama` under `./prod-usr/prod_tag/src/python/pygama`
* `pyfcutils` under `./prod-usr/prod_tag/src/python/pyfcutils`
By default, all packages are downloaded from the `legend-exp` organization and set to the `master` branch. The name of the organization and branch name can set with the `-o organization-name` and `-b branch-name` options. Users might consider to fork all these packages and set as organization their github username.

When the option `-p path-to-custom-src-dir` is specified, `pygama` and `pyfcutils` are not downloaded. The path to the custom src directory is stored in `config.json`. The custom directory should contains a `pygama` and `pyfcutils` folder.

The option `-c` allows to select the path of a specific singularity container. 

The structure of the production cycle is:
```
.
├── config.json
├── dataflow
├── gen
├── genpar
├── log
├── meta
├── src
│   └── python
│           ├── pygama
│           └── pyfcutils
└── venv
    └── default
```

*  `./config.json` contains paths to all main directories of the data production and 
* `./dataflow` contains the `snakemake` configuration files. This repository can be edited to modify the data-flow 
* `./gen`, `./genpar`, and `./log` are automatically generated during the data production
* `./src/python` contains the software used for data production. Users can edit these repositories. 
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

This script loads the container and pip install `pygama` and `pyfcutils`. The option `-r` can be used to fully remove the installation directory before the software is re-installed. 

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
