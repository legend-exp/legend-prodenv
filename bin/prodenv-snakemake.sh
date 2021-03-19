#!/bin/bash

\mkdir -p $PRODENV/tools
\cd $PRODENV/tools
\wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh 
\bash Miniconda3-latest-Linux-x86_64.sh -b -u -p miniconda3/
$PRODENV/tools/miniconda3/bin/conda install -y -c conda-forge mamba
$PRODENV/tools/miniconda3/bin/mamba create -y -c bioconda -c conda-forge -n snakemake snakemake-minimal
\ln -s $PRODENV/tools/miniconda3/envs/snakemake/bin/snakemake $PRODENV/bin/
