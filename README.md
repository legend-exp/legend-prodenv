# LEGEND Testing Environment

This repository provides an environment to handle multiple production cycles. It includes a file system structure and a set of scripts operating in it. The testing environment is currently limited to the `raw_to_dsp` step of the production.

## Workflow
The steps to create a new production cycle and process the data are:
* source the `setup.sh` to set the environmental variables of the testing environment
* run `testenv-init.sh` to create the initialize a new production cycle 
* customize the config.json file in the production cycle 
* run `testenv-build.sh` to install the code
* run `testenv-run-r2d.sh` to create the dsp files

Once a production cycle has been initialized, the usual workflow of a user developing/testing new routines is:
* source the `setup.sh`
* modify the pygama source code or the `processors_list.json`
* run `testenv-build.sh` to install the code
* remove the files produced by the previous production (e.g. `rm -r ./data/prod/dsp`)
* run `testenv-r2d.sh` to create the dsp files

A brief description of these steps is given in the following. Run the scripts with the option `-h` for further information on the arguments and options available.

### Source the setup file of the testing enviroment
```
$ source setup.sh
```

Sourcing the setup.sh file in the top directory of the testing environment will:
* set environmental variables storing the path to the test environment
* add the bin directory to the user's PATH to make the scripts available from the command line
* redefine the umask such that all files created by the user do not have write permissions for the group and others.


### Initialize a new production cycle
```
$ testenv-init.sh -o github-username -b branch-name production-cycle-tag
```

The` testenv-init.sh` script generates a new production cycle in `testenv/user-prod`. This includes the directory structure and a few illustrative configuration files. It will also download into a fresh version of pygama. Pygama will be cloned either from your fork (`-o github-username`) or from the legend-exp organization (default). It is possible to specify which branch to checkout through the `-b branch-name` option. Advanced users can keep on working on their existing pygama directory without downloading a new one. This can be linked to the production cycle by specifying the option `-p path/to/my-pygama`.

After the initialization the production cycle structure should look like this:
```
.
├── bin 
├── README.md
├── ref-prod
├── setup.sh
└── user-prod
    └── my-test-cycle
        ├── config.json
        ├── data
        │   ├── prod
        │   │   ├── daq
        │   │   ├── dsp
        │   │   ├── hit
        │   │   └── raw
        │   └── meta
        │       ├── daq
        │       ├── dsp
        │       │   └── processor_list.json
        │       ├── hit
        │       ├── keylists
        │       └── raw
        └── software
            ├── inst
            └── src
                └── python
                    └── pygama
```

This directory structure is still preliminary and it will be refined. The basic ideas behind the current structure are:
* each production cycle has a `./config.json` containing all configurations 
* `./software` contains both the source code (`./software/src`) and its installation (`./software/inst`)
* `./data` contains the original daq files (`./data/daq`), the generated data (`./data/prod/{raw,dsp,hit,...}`), the metadata (`./data/meta/{raw,dsp,hit,...,keylist). In the future the metadata directory will be replaced with a git repository


### Customize the config.json file
```
$ edit ./config.json
```

The main config file specifies all paths. At the moment it also includes some references to the metadata (e.g. the path to the processor list). These parts will be moved to the metadata directory when this becomes a structured repository.  Users will find that the path to the raw data is linked to a `ref-prod/master` production. This is intended for people who want to focus on the `raw_to_dsp` step of the analysis. 

### Install the software
```
$ testenv-build.sh /path/to/production/cycle/config.json
```

This script installs the software from the pygama `src` into the `inst` directory from which it will be executed. This script has to be executed every time the code is modified.


### Run raw_do_dsp data production
```
testenv-r2d.sh /path/to/production/cycle/config.json /path/to/keylist.txt
```

This script runs the production of the files in the keylist. Currently the keylist is an file with the current structure:
```
my-dir/my-file-1.lh5
my-dir/my-file-2.lh5
my-dir/my-file-3.lh5
```
The script will search for `./data/prod/raw/my-dir/my-file-1.lh5` and create
`./data/prod/dsp/my-dir/my-file-1.lh5`. 

The script does not overwrite files and exist when the output file already exist. Users should remove by hand their files before running a new production.

## Other scripts (run them with `-h` to get more info)
### Start debug shell
```
$ testenv-bash.sh /path/to/production/cycle/config.json
```
Returns a bash in which the python installation refers to the one of the production cycle. It can be useful for debugging the code

### Load python installation within the current shell
```
$ testenv-load.sh /path/to/production/cycle/config.json
```
Set the PYTHONPATH and PYTHONUSERBASE user base on the existing shell. Note that this script must be sourced

### Reset crrent shell
```
$ testenv-clean.sh /path/to/production/cycle/config.json
```
Removes the environmental variables related to the testing enrivoment. Note that not all settings of the bash can be fully restored

### Run pygama on single file
```
$ pygama-run.py -i input-file -o output-file -c config-file -s raw_to_dsp
```
Pygama Data Production Utility providing an interface to its main routines


## Contacts
Contact <matteo.agostini@ucl.ac.uk> for support and report bugs
