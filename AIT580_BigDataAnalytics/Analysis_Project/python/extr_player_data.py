"""
Extract match player data and save as a tsv file for later analysis

AIT 580 Analysis Project

Doug Cady
"""

import pandas as pd
from operator import attrgetter
from typing import List, NamedTuple
from tqdm import tqdm

# user py files
import utils


class SlotKillTime(NamedTuple):
    slot: int
    kill_time: int


def get_player_data(matches: List[str]) -> pd.DataFrame:
    """ Extract player data and find kills, deaths, xpm, gpm, and match duration """
    players_data = []
    fb_kill_mID_slots = set()

    for match in tqdm(matches):
        # Match level data
        mID = match['match_id']
        duration_min = round(match['duration'] / 60, 2)
        radiant_win = match['radiant_win']
        num_players = match['human_players']

        all_match_data = []
        all_kill_times = []
        match_kills = 0

        for player in match['players']:
            player_cols = ['player_slot', 'kills', 'deaths', 'assists',
                           'gold_per_min', 'xp_per_min', 'isRadiant', 'win',
                           # 'camps_stacked', 'creeps_stacked',
                           'hero_damage', 'hero_healing', 'last_hits', 'denies',
                           'tower_damage', 'rune_pickups', 'obs_placed', 'stuns']

            # Create combo key for identifying first blood player
            mID_slot = f"{mID}|{player['player_slot']}"

            # Get list of all kill times
            if (player['kills_log'] is not None) and (len(player['kills_log']) > 0):
            # if player['kills_log'] is not None:
                slot_kill_times = [SlotKillTime(player['player_slot'], kill['time'])
                                   for kill in player['kills_log']]
                all_kill_times.extend(slot_kill_times)
                match_kills += len(slot_kill_times)

            first_blood_kill = 0

            # Combine player and match level data
            match_level_data = [mID, mID_slot, duration_min, radiant_win, num_players]
            all_match_data.append(match_level_data + [player[col] for col in player_cols] + [first_blood_kill])
            # players_data.append(all_match_data)

        # Find slots of first blood killers
        if len(all_kill_times) > 0:
            fb_kill_mID_slots.add(f"{mID}|{min(all_kill_times, key=attrgetter('kill_time')).slot}")

        # if mID == 5449620942:
        #     print(f"{mID}|{min(all_kill_times, key=attrgetter('kill_time')).slot}")
        #     import pdb
        #     pdb.set_trace()
        #     print(sorted(all_kill_times, key=attrgetter('kill_time')))

        # Add match kills column to list
        upd_match_data = [pl_row + [match_kills] for pl_row in all_match_data]

        players_data.extend(upd_match_data)


    df_cols = ['match.id', 'match.id.slot', 'duration.min',
               'radiant.win', 'num.players'] + player_cols + ['first.blood', 'match.kills']

    df_players = pd.DataFrame(players_data, columns = df_cols).drop_duplicates()

    # -- remove matches will 0 total kills !! **********
    rm_no_kills = df_players[df_players['match.kills'] != 0].copy()

    rename_dict = {'player_slot': 'player.slot',
                   'gold_per_min': 'gold.p.min',
                   'xp_per_min': 'xp.p.min',
                   'hero_damage': 'hero.dmg',
                   'hero_healing': 'hero.heal',
                   'last_hits': 'last.hits',
                   'tower_damage': 'tower.dmg',
                   'rune_pickups': 'runes',
                   'obs_placed': 'obs.set'
    }

    rm_no_kills.rename(columns=rename_dict, inplace=True)

    # Update df with first blood killers
    rm_no_kills.loc[rm_no_kills['match.id.slot'].isin(fb_kill_mID_slots), 'first.blood'] = 1

    return rm_no_kills



if __name__ == '__main__':
    json_in_fn = '../input/match_data.json'

    matches = utils.load_match_json(json_in_fn=json_in_fn)

    match_kills = get_player_data(matches=matches)

    match_kills_out_fn = '../output/match_player_data_v2.tsv'
    utils.write_tsv(data=match_kills, fn=match_kills_out_fn)

    print("Player level data for each match:")
    print(f" - Saved {len(matches)} matches to output folder")



# Junk:
        # print(matches[0]['start_time'])
        # matches = json.loads(json_file)

    # print(matches[0]['match_id'])
    # print(matches[1]['match_id'])

    # matches[0].keys()

    # type(matches)
    # len(matches)
