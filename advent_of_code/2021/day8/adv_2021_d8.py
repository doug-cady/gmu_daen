"""
Advent of Code 2021
Day 8: Seven Segment Search

May 9, 2022

"""

import numpy as np
from typing import List


EX_INPUT = """3,4,3,1,2"""


def make_timer_counter(puz_input: List[str]) -> np.array:
    """Parse puzzle input and construct a timer counter array with each timer number
        as an index in the array with the values = count of that timer value.
    """
    fish_timers = np.array([int(x) for x in puz_input.split(",")])
    timer_counter = np.zeros(9)

    for timer in range(9):
        timer_counter[timer] = len(fish_timers[fish_timers == timer])

    return timer_counter


ex_timer_counter = make_timer_counter(puz_input=EX_INPUT)
assert np.array_equal(ex_timer_counter, np.array([0, 1, 1, 2, 1, 0, 0, 0, 0]))


def simulate(timer_counter: np.array, days: int) -> int:
    """Simulate days passing by decrementing timers by 1 each day until 0 when a
        new fish appears with timer 8 and the fishes at 0 reset to 6.
       Returns sum of counter as the number of lanternfish in the population after <days>.
    """
    for day in range(days):
        new_fishes = timer_counter[0]
        timer_counter = np.append(timer_counter[1:], np.array([new_fishes]))
        timer_counter[6] += new_fishes

    return int(sum(timer_counter))

assert simulate(timer_counter=ex_timer_counter.copy(), days=18) == 26
assert simulate(timer_counter=ex_timer_counter.copy(), days=80) == 5934


# Part 1: Final Puzzle Input
with open("adv_2021_d6_input.txt") as f:
    pt1_timer_counter = make_timer_counter(puz_input=f.read())
    print(simulate(timer_counter=pt1_timer_counter.copy(), days=80))


# Part 2: 256 days of Lanternfish!
assert simulate(timer_counter=ex_timer_counter.copy(), days=256) == 26_984_457_539

with open("adv_2021_d6_input.txt") as f:
    pt2_timer_counter = make_timer_counter(puz_input=f.read())
    print(simulate(timer_counter=pt2_timer_counter.copy(), days=256))
