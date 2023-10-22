# LEGEND Data Production Environment

Data production environment to handle multiple production cycles. It provides a
file system structure and a set of Python scripts. Within each production
cycle, data can be automatically generated using
[Snakemake](https://snakemake.github.io/) and
[legend-dataflow](https://github.com/legend-exp/legend-dataflow).


## Workflow

Installation of Snakemake:

* source `setup.sh` to set some environmental variables
* run `prodenv-tools`

Creation of a new production cycle:

* source `setup.sh` to set some environmental variables
* run `dataprod-init-cycle` to initialize a new production cycle
* customize the `config.json` file in the production cycle directory
* check-out specific version of `pygama`, `pyfcutils`, `legend-dataflow`, `legend-metadata`
* run `dataprod-install-sw` to install the software in `venv`
* run `snakemake` to populate the multi-tier data structure

Workflow for existing production cycles:

* source `setup.sh` to set some environmental variables
* customize `pygama`, `pyfcutils`, `legend-dataflow-hades`, `legend-metadata`
* run `dataprod-install-sw` to reinstall the software
* remove all files in `gen/` and `genpar/` that need to be reprocessed
* run `snakemake` to update the multi-tier data structure


### Source the setup file of the production  environment

```
$ source setup.sh
```

Sourcing the `setup.sh` file located at the top level of the production environment. Sourcing the file will:
* set data production environmental variables (the name of all variables start with `PRODENV`)
* add `./bin/` and `./tools/bin/` to PATH, making scripts and tools available from command line

The content of the source file can also be copied to the users's shell configuration file.


### Initialize a new production cycle

```console
$ dataprod-init-cycle  -h
usage: dataprod-init-cycle [-h] [-c] rpath

Initialize a new production cycle

positional arguments:
  rpath       relative path of directory in which the production cycle will be created

options:
  -h, --help  show this help message and exit
  -c          clone pygama and pylegendmeta
```

The only mandatory option of the script is `rpath`, i.e. the path to the
production cycle directory. The scripts generates a file-system structure under
`./rpath/` and, by default, it clones:
* `legend-dataflow` under `./rpath/dataflow`
* `legend-metadata` under `./rpath/inputs`
* `pygama` under `./prod-usr/prod_tag/src/python/pygama`
* `pyfcutils` under `./prod-usr/prod_tag/src/python/pyfcutils`

By default, all packages are downloaded from the `legend-exp` organization and
set to the `main` branch.

When the option `-c` is specified, `pygama` and `pyfcutils` are downloaded. The
path to the custom `software` directory is stored in `config.json`. The custom
directory will contain a `pygama` and `pyfcutils` folder.

The structure of the production cycle is:
```
.
├── config.json
├── dataflow
├── generated
│   ├── log
│   ├── par
│   ├── plt
│   ├── tier
│   └── tmp
├── inputs
└── software
```

* `config.json` contains paths to all main directories of the data production and
* `dataflow` contains the Snakemake configuration files. This repository
  can be edited to modify the data flow
* `generated` and subdirectories are automatically generated during the data
  production
* `software` contains the software used for data production. Users can edit
  these repositories.


### Install the software

```console
$ dataprod-install-sw -h
usage: dataprod-install-sw [-h] [-r] config_file

Install user software in data production environment

positional arguments:
  config_file  production cycle configuration file

optional arguments:
  -h, --help   show this help message and exit
  -r           remove software directory before installing software

```

This script loads the container and pip-installs `pygama` and `pyfcutils`. The
option `-r` can be used to fully remove the installation directory before the
software is re-installed.


### Load Container
```console
$ dataprod-load-sw -h
usage: dataprod-load-sw [-h] config_file

Load data production environment

positional arguments:
  config_file  production cycle configuration file

optional arguments:
  -h, --help   show this help message and exit
```
It loads the container and all the software installed. Type exit to quit.


### Run Data Production

Data can be automatically produced through commands such as:
```console
$ snakemake \
    --snakefile path-to-dataflow-dir/Snakefile \
    -j 20 \
    --configfile=path-to-cycle/config.json \
    all-B00000B-co_HS5_top_dlt-tier2.gen
```

Documentation on how to run snakemake is available at
[legend-dataflow](https://github.com/legend-exp/legend-dataflow).


## Contacts

Contact <matteo.agostini@ucl.ac.uk> for support and report bugs
