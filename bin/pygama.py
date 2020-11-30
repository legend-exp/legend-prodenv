#!/usr/bin/env python3

import sys, os, argparse, json
from pygama.io.raw_to_dsp import raw_to_dsp


def main():
    doc="""
    Testenv data processing routine.
    """
    rthf = argparse.RawTextHelpFormatter
    par = argparse.ArgumentParser(description=doc, formatter_class=rthf)
    arg, st, sf = par.add_argument, 'store_true', 'store_false'

    # options
    arg('-i', '--input_file',  nargs=1, type=str, help='input file name',      required=True)
    arg('-o', '--output_file', nargs=1, type=str, help='output file name',     required=True)
    arg('-c', '--config_file', nargs=1, type=str, help='output file name',     required=True)
    arg('-r', '--routine',     nargs=1, type=str, help='data production step', required=True)

    arg('-n', '--event_number', nargs=1, type=int, help='limit num. waveforms')
    arg('-r', '--recreate',     action=st, help='recreate output file')
    arg('-v', '--verbose',      action=st, help='verbose mode')


    arg('--daq_to_raw', action=st, help='run daq_to_raw')
    arg('--raw_to_dsp', action=st, help='run raw_to_dsp')
    arg('--dsp_to_hit', action=st, help='run dsp_to_hit')

    args = par.parse_args()

    # input file
    f_input  = args.input_file
    if not os.path.exists(f_ouptut):
        print('  error: input file does not exist')
        exit()

    # output file
    f_ouptut = args.output_file
    if os.path.exists(f_ouptut) and args.recreate:
        os.remove(f_output)

    # config file
    f_config  = args.config_file
    if not os.path.exists(f_config):
        print('  error: config file does not exist')
        exit()
    with open(config_file) as f:
        config_dic = json.load(f, object_pairs_hook=OrderedDict)

    if args.verbose:
        print('  input:',  f_input)
        print('  output:', f_output)
        print('  config:', f_output)

    # -- run routines in order --
    if args.routines == 'daq_to_raw': 
        print('  error: data production step not implemented yet')
    elif args.routines == 'raw_to_dsp': 
        raw_to_dsp(f_input,f_output, config_dic, n_max=args.event_number, args.verbose, overwrite=false)
    elif args.routines == 'dsp_to_hit': 
        print('  error: data production step implemented yet')
    else:
        print('  error: data produciton step not known');

if __name__=="__main__":
    main()
