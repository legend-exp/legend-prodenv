#!/usr/bin/env python3

import sys, os, argparse, json
from collections import OrderedDict
from pygama.io.raw_to_dsp import raw_to_dsp

def main():
    doc="""
    Pygma Data Processing Utility
    """
    # options
    parser = argparse.ArgumentParser(description='Pygama Data Processing Utility')
    parser.add_argument('-i', '--input-file',  help='path/name of the input file',           required=True)
    parser.add_argument('-o', '--output-file', help='path/name of output file',              required=True)
    parser.add_argument('-c', '--config-file', help='path/name of the config file',          required=True)
    parser.add_argument('-s', '--step',        help='data production step (e.g. raw_to_dsp)',required=True)

    parser.add_argument('-v', '--verbose',  help='increase output verbosity', action="store_true")

    args = parser.parse_args()

    # dump info
    print('Pygama Data Processing Utility')
    if args.verbose: 
        print('  Running {args.step} step')
        print('  Input file: {args.input_file}')
        print('  Output file: {args.output_file}')
        print('  Config file: {args.config_file}')

    # input file
    f_input  = args.input_file
    if not os.path.exists(f_input):
        print('  Error: input file does not exist')
        exit()

    # output file
    f_output = args.output_file
    if os.path.exists(f_output):
        print('  Error: output file alrady exists')
        exit()

    # config file
    f_config  = args.config_file
    if not os.path.exists(f_config):
        print('  Error: config file does not exist')
        exit()
    with open(f_config) as f:
        config_dic = json.load(f, object_pairs_hook=OrderedDict)

    if   args.step == 'daq_to_raw': print('  Error: data production step not implemented yet')
    elif args.step == 'raw_to_dsp': raw_to_dsp(f_input,f_output, config_dic, verbose=args.verbose, overwrite=False)
    elif args.step == 'dsp_to_hit': print('  Error: data production step not implemented yet')
    else:                           print('  Error: data produciton step not known');

if __name__=="__main__":
    main()
