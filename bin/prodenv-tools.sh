#!/bin/bash

ORIGDIR=$PWD
\mkdir -p $PRODENV/tools/bin
\cd $PRODENV/tools

# install venv
\git clone git@github.com:oschulz/singularity-venv.git venv
\ln -s ../venv/bin/venv bin/

# install snakemake
\wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh 
\bash Miniconda3-latest-Linux-x86_64.sh -b -u -p snakemake-miniconda3/
snakemake-miniconda3/bin/conda install -y -c conda-forge mamba
snakemake-miniconda3/bin/mamba create -y -c bioconda -c conda-forge -n snakemake snakemake-minimal
\ln -s ../snakemake-miniconda3/envs/snakemake/bin/snakemake bin/
\ln -s ../snakemake-miniconda3/envs/snakemake/bin/python3 bin/python3-snakemake
\rm Miniconda3-latest-Linux-x86_64.sh

cd $ORIGDIR
