"""
Advent of Code 2021
Day 7: Treachery of Whales

May 8, 2022

"""

import numpy as np
import itertools as it
from typing import List


EX_INPUT = """16,1,2,0,4,2,7,1,2,14"""

ex_pos = np.array([np.int64(x) for x in EX_INPUT.split(',')])


# --------------------------------------------------------------------------------------------------
# Part 1: Get all crabs to same horizontal position with least fuel used
# --------------------------------------------------------------------------------------------------
def align_crabs_pos(crab_pos: List[int]) -> int:
    """Move all crabs to same position and calculate sum of fuel spent to do so."""
    fuel_by_pos = {}

    pos_guess = np.int64(np.median(crab_pos))

    for sign, mult in zip(it.cycle([1, -1]), range(1, 100)):
        pos_guess_arr = np.array([pos_guess] * len(crab_pos))
        fuel = sum(abs(pos_guess_arr - crab_pos))
        fuel_by_pos[fuel] = pos_guess

        pos_guess += sign * mult

    min_fuel = min(fuel_by_pos.keys())

    return min_fuel, fuel_by_pos[min_fuel]


assert align_crabs_pos(crab_pos=ex_pos) == (37, 2)


# Part 1 puzzle input
puz_input = open('adv_2021_d7_input.txt').read()
puz_pos = np.array([np.int64(x) for x in puz_input.split(',')])
min_fuel, pt1_crab_pos = align_crabs_pos(crab_pos=puz_pos)
print(f"min_fuel: {min_fuel} | pt1_crab_pos: {pt1_crab_pos}")


# --------------------------------------------------------------------------------------------------
# Part 2: Fuel spent is no longer static at 1 per position, but now increases by 1 for
# each position moved.  First step costs 1, then 2, 3, ...
# --------------------------------------------------------------------------------------------------
def calc_fuel_spent(np_ele: int) -> int:
    """Calculate fuel spent for a given numpy array element."""
    return sum([x for x in range(1, np_ele + 1)])


assert calc_fuel_spent(2) == 3
assert calc_fuel_spent(4) == 10


def align_crabs_pos_inc(crab_pos: List[int]) -> int:
    """Move all crabs to same position and calculate sum of fuel spent to do so."""
    fuel_by_pos = {}

    pos_guess = np.int64(np.median(crab_pos))

    for sign, mult in zip(it.cycle([1, -1]), range(1, 1_000)):
        pos_guess_arr = np.array([pos_guess] * len(crab_pos))
        fuel_diff = abs(pos_guess_arr - crab_pos)
        fuel = sum(np.vectorize(calc_fuel_spent)(y) for y in fuel_diff)
        fuel_by_pos[fuel] = pos_guess

        pos_guess += sign * mult

    min_fuel = min(fuel_by_pos.keys())

    return min_fuel, fuel_by_pos[min_fuel]


assert align_crabs_pos_inc(crab_pos=ex_pos) == (168, 5)


# Part 2 puzzle input
min_fuel, pt2_crab_pos = align_crabs_pos_inc(crab_pos=puz_pos)
print(f"min_fuel: {min_fuel} | pt1_crab_pos: {pt2_crab_pos} | max_puz_pos: {max(puz_pos)}")
