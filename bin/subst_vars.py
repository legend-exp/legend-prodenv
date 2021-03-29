#!/usr/bin/env python3-snakemake

import sys, argparse, json
import re,os, shutil, copy, string

def subst_vars_impl(x, var_values, ignore_missing = False):
    if isinstance(x, str):
        if '$' in x:
            if ignore_missing:
                return string.Template(x).safe_substitute(var_values)
            else:
                return string.Template(x).substitute(var_values)
        else:
            return x
    if isinstance(x, dict):
        for key in x:
            value = x[key]
            new_value = subst_vars_impl(value, var_values, ignore_missing)
            if new_value is not value:
                x[key] = new_value
        return x
    if isinstance(x, list):
        for i in range(len(x)):
            value = x[i]
            new_value = subst_vars_impl(value, var_values, ignore_missing)
            if new_value is not value:
                x[i] = new_value
        return x
    else:
        return x

def subst_vars(props, var_values = {}, use_env = False, ignore_missing = False):
    combined_var_values = var_values
    if use_env:
        combined_var_values = {k: v for k, v in iter(os.environ.items())}
        combined_var_values.update(copy.copy(var_values))
    subst_vars_impl(props, combined_var_values, ignore_missing)

def main():
    config_file = sys.argv[1]
    if not os.path.exists(config_file):
        exit()

    config_dic = json.load(open(config_file))
    subst_vars(
        config_dic,
        var_values = {'_': os.path.dirname(os.path.abspath(config_file))},
        use_env = True, ignore_missing = False
    )
    print(config_dic)

if __name__=="__main__":
    main()
