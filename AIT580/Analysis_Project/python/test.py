import pandas as pd
from typing import List


def get_match_ids(fn: str) -> List[str]:
    """ Get unique set of match ids to make api calls later """
    match_ids_df = pd.read_csv(fn)

    return list(match_ids_df['match_id'].unique())


match_ids_fn = '../input/dota2_2020-06-02_2020-09-17.csv'
match_ids = get_match_ids(fn=match_ids_fn)

data_fn = '../output/match_player_data.tsv'
data = pd.read_csv(data_fn, sep='\t')f

dupes = data[data['match_id_slot'].duplicated()]
print(dupes)

data[data['match_id'] == 5536512014]
print(len(data))

print(len(data.drop_duplicates()))

import utils
match_kills_out_fn = '../output/match_player_data.tsv'
utils.write_tsv(data=data.drop_duplicates(), fn=match_kills_out_fn)

data_ids = set(data['match_id'])

missing_mIDs = set(match_ids) - data_ids
print(len(missing_mIDs))

match_ids.index(list(missing_mIDs)[0])
match_ids.index(list(missing_mIDs)[1])

# import csv
# # cw = csv.writer(open('../input/missing_mIDs.csv', 'w'))
# # cw.writerow(list(missing_mIDs))
# with open('../input/missing_mIDs.txt', 'w') as outfile:
#     # write(list(missing_mIDs))
#     writer = csv.writer(outfile)

#     writer.writerow(list(missing_mIDs))
