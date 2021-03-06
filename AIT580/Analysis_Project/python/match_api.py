"""
Main file to get match data from list of input match_ids

AIT 580 Analysis Project

Doug Cady
"""

import pandas as pd
import requests
import json
from tqdm import tqdm
from typing import List


def get_match_ids(fn: str) -> List[str]:
    """ Get unique set of match ids to make api calls later """
    match_ids_df = pd.read_csv(fn)

    return list(match_ids_df['match_id'].unique())


# def chunks(lst: List[str], n: int) -> List[str]:
#     """Yield successive n-sized chunks from lst."""
#     for i in tqdm(range(0, len(lst), n)):
#         yield lst[i:i + n]

def chunks(lst: List[str], n: int) -> List[str]:
    """ Return successive n-sized chunks from lst. """
    n = max(1, n)
    # return (lst[i:i + n] for i in range(, 50, n))
    return (lst[i:i + n] for i in range(11, len(lst), n))


def get_match_data(opendota_api: str, match_ids: List[int]) -> None:
    """ Use requests package to Get match data from OpenDota api """
    matches = []
    chunk_id = 2140

    for chunk in chunks(match_ids, 5):
        # print(f"{chunk_id*5}-{(chunk_id+1)*5}")
        print(chunk_id)
        matches = []

        for match_id in chunk:
            resp = requests.get(url = opendota_api + str(match_id))
            # print(f"match_id: {match_id}, status_code: {resp.status_code}")
            if resp.status_code == 200:
                # print(f"match_id: {match_id}, success")
                matches.append(resp.json())

        save_as_json(match_data=matches, json_out_fn=f"../input/dota2_exp_get/match_data_{chunk_id}.json")
        chunk_id += 1

    print(f"Got {len(matches)} matches from OpenDota API.")


def save_as_json(match_data: List[str], json_out_fn: str) -> None:
    """ Save match data as json file for use in analysis programs """
    with open(json_out_fn, 'w') as json_file:
        json.dump(match_data, json_file)


if __name__ == '__main__':
    match_id_list_fn = '../input/dota2_2020-06-02_2020-09-17.csv'
    match_ids = get_match_ids(fn=match_id_list_fn)[0:2]
    # print(f"Loaded {len(match_ids)} match IDs.")

    opendota_api = 'https://api.opendota.com/api/matches/'

    get_match_data(opendota_api=opendota_api, match_ids=match_ids)
