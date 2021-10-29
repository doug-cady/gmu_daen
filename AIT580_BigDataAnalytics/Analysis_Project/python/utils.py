"""
Functions only utility file
"""

import json
import pandas as pd
from typing import List


def load_match_json(json_in_fn: str) -> List[str]:
    """ Load match data json file and return in json format """
    with open(json_in_fn, 'r') as json_file:
        matches = json_file.readlines()

        for match in matches:
            match_json = json.loads(match)

        return match_json


def write_tsv(data: pd.DataFrame, fn: str) -> None:
    """ Save dataframe to tab-separated value format """
    data.to_csv(fn, sep='\t', index = False)
