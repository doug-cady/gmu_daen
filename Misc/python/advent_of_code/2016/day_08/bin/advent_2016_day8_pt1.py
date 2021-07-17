"""
Advent of Code 2016
Day 8: Two-Factor Authentication

url: https://adventofcode.com/2016/day/8

"""

import pytest
import sys
import numpy as np
from typing import List


def test_add_rectangle() -> None:
    InputScreen = Screen(wide=7, tall=3, proc=test_proced)
    print("Init:")
    print(InputScreen)

    InputScreen.add_rectangle(wide=3, tall=2)
    print("\nAdded 3x2 rect:")
    print(InputScreen)

    obs_result = InputScreen.grid
    exp_result = np.array([['#']*3 + ['.']*4,
                           ['#']*3 + ['.']*4,
                           ['.']*7])

    assert np.array_equal(obs_result, exp_result)



class Screen():
    def __init__(self, wide: int, tall: int, proc: str = "") -> None:
        self.grid = np.array([['.'] * wide] * tall)


    def __repr__(self) -> str:
        return '\n'.join(''.join(pix for pix in row) for row in self.grid)


    def add_rectangle(self, wide: int, tall: int) -> None:
        """Turn on all pixels inside rectangle in top-left corner."""
        self.grid[0:tall, 0:wide] = '#'


    # def parse_input(self, proc: str) -> List[str]:
    #     """Split input procedure on newlines to return a list of instructions."""
    #     return [e.strip() for e in proc.split('\n') if e != '']


    # def make_beg_keypad(self, nums: int) -> List[List[int]]:
    #     """Creates a matrix of n consecutive numbers across rows and returns a matrix."""
    #     keypad_nums = list(range(1, nums + 1))
    #     beg_keypad = [keypad_nums[i:i + self.keyrows]
    #                   for i in range(0, len(keypad_nums), self.keyrows)]
    #     return beg_keypad


    # def move(self, instr: str) -> None:
    #     """Updates rows and cols by processing next instruction."""
    #     dirs = {
    #         'U': np.array([-1, 0]),
    #         'D': np.array([1, 0]),
    #         'R': np.array([0, 1]),
    #         'L': np.array([0, -1]),
    #     }
    #     next_move = np.array([self.row, self.col]) + dirs[instr]

    #     if self.is_valid(next_move=next_move):
    #         self.row, self.col = next_move


    # def is_valid(self, next_move: np.array) -> bool:
    #     """Identifies if next button instruction is a valid move within keypad dims."""
    #     row, col = next_move
    #     if (0 <= row <= self.keyrows - 1) & (0 <= col <= self.keyrows - 1):
    #         return True
    #     else:
    #         return False


    # def exec_instructions(self) -> str:
    #     """Execute instructions in loop and move accordingly."""
    #     bathroom_code = ""

    #     for line in self.proc_list:
    #         for instr in line:
    #             self.move(instr=instr)

    #         bathroom_code += str(self.keypad[self.row][self.col])

    #     return bathroom_code


test_proced = """rect 3x2
rotate column x=1 by 1
rotate row y=0 by 4
rotate column x=1 by 1"""


# Main ------------------------------------------------------------------------
def main() -> int:
    # Test puzzle input
    input_proced = test_proced

    # Final puzzle input
    # with open("../data/puz_input_2016_d8_pt1.txt", 'r') as f:
    #     input_proced = f.read()

    test_add_rectangle()

    return 0



if __name__ == '__main__':
    sys.exit(main())
