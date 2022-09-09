#!/usr/bin/env python3
"""Save json with pretty formatting.

**Author: Jonathan Delgado**

"""
#------------- Imports -------------#
import sys
import json
#--- Custom imports ---#
# from tools.config import *
#------------- Fields -------------#
__version__ = 0.00
#======================== Helper ========================#



#======================== Entry ========================#


def main():
    fname = sys.argv[-1] + '.json'
    with open(fname, 'r') as f: json_data = json.load(f)

    # Dump with indenting
    with open(fname, 'w') as f: json.dump(json_data, f, indent=4)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt as e:
        print('Keyboard interrupt.')