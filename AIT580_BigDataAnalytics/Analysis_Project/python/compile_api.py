"""
Compile all json files saved from API calls

AIT 580 Analysis Project

Doug Cady
"""

import pandas as pd
import os
import json
from typing import List


def merge_JsonFiles(files: List[str], in_path: str, out_fn: str) -> None:
    """ Merge list of files into 1 single json file """
    result = list()
    for f1 in files:
        f1_path = os.path.join(in_path, f1)
        with open(f1_path, 'r') as infile:
            result.extend(json.load(infile))

    with open(out_fn, 'w') as output_file:
        json.dump(result, output_file)


if __name__ == '__main__':
    json_folder = '../input/dota2_exp_get/'

    files = [fn for fn in os.listdir(json_folder)]

    out_fn = '../input/match_data.json'

    merge_JsonFiles(files=files, in_path=json_folder, out_fn=out_fn)
