"""
Advent of Code 2016
Day 10: Balance Bots [Part 1]

url: https://adventofcode.com/2016/day/10

"""

import sys
import numpy as np
from math import prod
from collections import defaultdict
from copy import deepcopy
from itertools import cycle
from typing import List, DefaultDict, Tuple


test_input = """value 5 goes to bot 2
bot 2 gives low to bot 1 and high to bot 0
value 3 goes to bot 1
bot 1 gives low to output 1 and high to bot 0
bot 0 gives low to output 2 and high to output 0
value 2 goes to bot 2"""


def test_init_bots() -> None:
    bot_test = BotBalance(instrs=test_input.split('\n'), comp_2_chips=[])
    obs_dict = bot_test.in_bots

    exp_dict = defaultdict(list)
    exp_dict['2'].append(5)
    exp_dict['1'].append(3)
    exp_dict['2'].append(2)

    assert obs_dict == exp_dict


def test_parse_input() -> None:
    bot_test = BotBalance(instrs=test_input.split('\n'), comp_2_chips=[])
    bot_test.move()
    obs_moved_bots = bot_test.move_bots
    obs_output = bot_test.output

    exp_moved_bots = defaultdict(list)
    exp_moved_bots['2'] = []
    exp_moved_bots['1'] = []
    exp_moved_bots['0'] = []
    assert obs_moved_bots == exp_moved_bots

    exp_output = defaultdict(list)
    exp_output['1'].append(2)
    exp_output['2'].append(3)
    exp_output['0'].append(5)
    assert obs_output == exp_output


class BotBalance:
    def __init__(self, instrs: List[str], comp_2_chips: List[str]):
        self.instrs = instrs
        self.init_instrs = self.extract_instrs_by_type(instr_type='val')
        self.move_instrs = self.extract_instrs_by_type(instr_type='bot')
        self.in_bots = self.init_bots()
        self.move_bots = deepcopy(self.in_bots)
        self.output = defaultdict(list)
        self.comp_2_chips = comp_2_chips


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
            bots[bot].append(int(val))

        return bots


    def assign_values(self, val: int, rec: str, rec_num: str) -> None:
        """Assign val to the recipient "rec" with rec_num and return updated dictionaries."""
        if rec == 'bot':
            self.move_bots[rec_num].append(val)
        else:
            self.output[rec_num].append(val)


    def bot_has_2_chips(self, bot: str) -> bool:
        if len(self.move_bots.get(bot, [])) == 2:
            return True
        else:
            return False


    def move(self) -> None:
        """Move bots according to move instructions and return archive of bots with max values."""
        used_moves = set()
        self.compare_bots = set()
        idx = 0

        while len(self.move_instrs) != len(used_moves):
            instr = self.move_instrs[idx]
            idx += 1

            if instr not in used_moves:
                """bot [2] gives [low] to [bot] [1] and [high] to [bot] [0]"""
                _, giver, _, _, _, lo_rec, lo_rec_num, _, _, _, hi_rec, hi_rec_num = instr.split(' ')

                if self.bot_has_2_chips(bot=giver):
                    idx = 0
                    used_moves.add(instr)
                    lo, hi = sorted(self.move_bots[giver])

                    if [hi, lo] == self.comp_2_chips:
                        self.bot_compare_ans = giver
                        # break

                    self.move_bots[giver] = [] # giver bot is emptied

                    self.assign_values(val=lo, rec=lo_rec, rec_num=lo_rec_num)
                    self.assign_values(val=hi, rec=hi_rec, rec_num=hi_rec_num)



def parse_input(puz_input: List[str], comp_2_chips: List[int]) -> Tuple[str, int]:
    """Parse puzzle input, then split value and move instructions."""
    bot_bal_input = BotBalance(instrs=puz_input, comp_2_chips=comp_2_chips)
    bot_bal_input.move()
    output_012 = prod(sum([bot_bal_input.output[num] for num in ['0', '1', '2']], []))
    return bot_bal_input.bot_compare_ans, output_012



# Main ------------------------------------------------------------------------
def main() -> int:
    test_init_bots()
    test_parse_input()

    # Final puzzle input
    with open("../data/puz_input_2016_d10_pt1.txt", 'r') as f:
        puz_input = [line for line in f.read().split('\n') if line != '']

    comp_2_chips = [61, 17]
    bot_compare_ans, output_012_mult = parse_input(puz_input=puz_input, comp_2_chips=comp_2_chips)
    print(f"[Part 1] - Bot {bot_compare_ans} compares the {comp_2_chips} microchips.")

    print(f"[Part 2] - Output012 multiplied = {output_012_mult}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
