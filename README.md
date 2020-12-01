# LEGEND Testing Enviroment

This repository provides an environment and set of scripts to create new production cycles and handle them. The typical workflow for a user follows these steps:
###### `$ source setup.sh`
Sourcing the setup.sh file in the top directory of the testing enviroment will:
* set enviromental variables storing the path to the enviroment
* add the bin directory to the user's PATH
* redefine the umask such that all files created by the user do not have write permissions for the group and others.

###### `$ testenv-init.sh -o github-username -b branch-name production-cycle-tag`
The` testenv-init.sh` script generates a new production cycle in testenv/user-prod. This includes the directory structure and a few illustrative config files. It will also download into the production cycle a fresh version of pygama. Pyganma will be cloned either from your fork (`-o github-username`) or from the legend-exp organiation (default). It is possible to specify the branch to checkout through the `-b branch-name` option. Advanced users can keep on working on their existing pygama directory without downloading a new one. This can be linked to the production cycle by specifying the option `-p path/to/my-pygama'.

After initializing the production cycle structure should look like this:
```
.
├── bin
│   ├── pygama-run.py
│   ├── testenv-bash.sh
│   ├── testenv-build.sh
│   ├── testenv-clean.sh
│   ├── testenv-init.sh
│   ├── testenv-load.sh
│   └── testenv-run.sh
├── README.md
├── ref-prod
├── setup.sh
└── user-prod
    ├── my-test-cycle
        ├── config.json
        ├── data
        │   ├── daq
        │   ├── gen
        │   │   ├── dsp
        │   │   ├── hit
        │   │   └── raw
        │   └── meta
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

