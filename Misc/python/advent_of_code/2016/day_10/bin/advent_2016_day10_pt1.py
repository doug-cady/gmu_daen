"""
Advent of Code 2016
Day 10: Balance Bots [Part 1]

url: https://adventofcode.com/2016/day/10

"""

import pytest
import sys
import numpy as np
from collections import defaultdict
from typing import List, DefaultDict


test_input = """value 5 goes to bot 2
bot 2 gives low to bot 1 and high to bot 0
value 3 goes to bot 1
bot 1 gives low to output 1 and high to bot 0
bot 0 gives low to output 2 and high to output 0
value 2 goes to bot 2"""


def test_init_bots() -> None:
    bot_test = BotBalance(instrs=test_input.split('\n'))
    obs_dict = bot_test.in_bots

    exp_dict = defaultdict(list)
    exp_dict['2'].append('5')
    exp_dict['1'].append('3')
    exp_dict['2'].append('2')

    assert obs_dict == exp_dict


def test_parse_input() -> None:
    bot_test = BotBalance(instrs=test_input.split('\n'))
    bot_test.move()
    obs_moved_bots = bot_test.move_bots
    obs_bots_archive = bot_test.bots_archive
    obs_output = bot_test.output

    exp_moved_bots = defaultdict(list)
    print(obs_moved_bots)
    assert obs_moved_bots == exp_moved_bots

    exp_bots_archive = defaultdict(list)
    exp_bots_archive['2'].append('5')
    exp_bots_archive['1'].append('3')
    exp_bots_archive['2'].append('2')
    exp_bots_archive['1'].append('2')
    exp_bots_archive['0'].append('5')
    exp_bots_archive['0'].append('3')
    assert obs_bots_archive == exp_bots_archive

    exp_output = defaultdict(list)
    exp_output['1'].append('2')
    exp_output['2'].append('3')
    exp_output['0'].append('5')
    assert obs_output == exp_output



class BotBalance:
    def __init__(self, instrs: List[str]):
        self.instrs = instrs
        self.init_instrs = self.extract_instrs_by_type(instr_type='val')
        self.move_instrs = self.extract_instrs_by_type(instr_type='bot')
        self.in_bots = self.init_bots()
        self.bots_archive = self.in_bots
        self.move_bots = self.in_bots
        self.output = defaultdict(list)


    def extract_instrs_by_type(self, instr_type: str) -> List[str]:
        return [instr for instr in self.instrs if instr[0] == instr_type[0]]


    def init_bots(self) -> DefaultDict[str, List[str]]:
        """Initialize bots with given input value instructions.
            Instructions are in form "value 5 goes to bot 2"
        """
        bots = defaultdict(list)

        for instr in self.init_instrs:
            """value [5] goes to bot [2]"""
            _, val, _, _, _, bot = instr.split(' ')
            bots[bot].append(val)

        return bots


    def assign_values(self, val: str, rec: str, rec_num: str) -> None:
        """Assign val to the recipient "rec" with rec_num and return updated dictionaries."""
        print(f"gives val {val} to {rec} {rec_num}")

        if rec == 'bot':
            self.move_bots[rec_num].append(val)
            self.bots_archive[rec_num].append(va)
        else:
            self.output[rec_num].append(val)


    def move(self) -> None:
        """Move bots according to move instructions and return archive of bots with max values."""
        output = defaultdict(list)

        for instr in instrs:
            """bot [2] gives [low] to [bot] [1] and [high] to [bot] [0]"""
            _, giver, _, _, _, lo_rec, lo_rec_num, _, _, _, hi_rec, hi_rec_num = instr.split(' ')
            lo, hi = sorted(self.move_bots[giver])
            self.move_bots[giver] = [] # bot is empty now

            self.assign_values(val=lo, rec=lo_rec, rec_num=lo_rec_num)
            self.assign_values(val=hi, rec=hi_rec, rec_num=hi_rec_num)


def parse_input(puz_input: List[str]) -> int:
    """Parse puzzle input, then split value and move instructions."""
    bot_test = BotBalance(instrs=test_input)

    bots = init_bots(instrs=init_value_instrs)

    bot_value_compares = move(in_bots=bots, instrs=move_instrs)


# Main ------------------------------------------------------------------------
def main() -> int:
    test_init_bots()
    test_parse_input()

    # Final puzzle input
    # with open("../data/puz_input_2016_d9_pt1.txt", 'r') as f:
    #     input_proc = f.read().split('\n')

    # decomp_len = parse_instructions(proc=input_proc)
    # print(f"Length: {decomp_len:,}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
