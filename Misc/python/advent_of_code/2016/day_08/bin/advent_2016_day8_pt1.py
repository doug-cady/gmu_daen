"""
Advent of Code 2016
Day 8: Two-Factor Authentication

url: https://adventofcode.com/2016/day/8

"""

import pytest
import sys
import numpy as np
from typing import List


def test_add_rectangle(class_obj) -> None:
    print("Init:")
    print(class_obj)

    class_obj.add_rectangle(wide=3, tall=2)
    print("\nAdded 3x2 rect:")
    print(class_obj)

    obs_result = class_obj.grid
    exp_result = np.array([['#']*3 + ['.']*4,
                           ['#']*3 + ['.']*4,
                           ['.']*7])

    assert np.array_equal(obs_result, exp_result)


def test_rotate_col(class_obj) -> None:
    class_obj.rotate_axis(axis="column", idx=1, pixels=1)

    print("\nRotate column x=1 by 1:")
    print(class_obj)

    obs_result = class_obj.grid
    exp_result = np.array([['#'] + ['.'] + ['#'] + ['.']*4,
                           ['#']*3 + ['.']*4,
                           ['.'] + ['#'] + ['.']*5])

    assert np.array_equal(obs_result, exp_result)


def test_rotate_row(class_obj) -> None:
    class_obj.rotate_axis(axis="row", idx=0, pixels=4)

    print("\nRotate row y=0 by 4:")
    print(class_obj)

    obs_result = class_obj.grid
    exp_result = np.array([['.']*4 + ['#'] + ['.'] + ['#'],
                           ['#']*3 + ['.']*4,
                           ['.'] + ['#'] + ['.']*5])

    assert np.array_equal(obs_result, exp_result)


def test_rotate_col_2(class_obj) -> None:
    class_obj.rotate_axis(axis="column", idx=1, pixels=1)

    print("\nRotate column x=1 by 1:")
    print(class_obj)

    obs_result = class_obj.grid
    exp_result = np.array([['.'] + ['#'] + ['.']*2 + ['#'] + ['.'] + ['#'],
                           ['#'] + ['.'] + ['#'] + ['.']*4,
                           ['.'] + ['#'] + ['.']*5])

    assert np.array_equal(obs_result, exp_result)



class Screen():
    def __init__(self, wide: int, tall: int, proc: str = "") -> None:
        self.grid = np.array([['.'] * wide] * tall)
        self.grid_width = wide
        self.grid_tall = tall
        self.proc = proc


    def __repr__(self) -> str:
        return '\n'.join(''.join(pix for pix in row) for row in self.grid)


    def add_rectangle(self, wide: int, tall: int) -> None:
        """Turn on all pixels inside rectangle in top-left corner."""
        self.grid[0:tall, 0:wide] = '#'


    def rotate_axis(self, axis: str, idx: int, pixels: int) -> None:
        """Rotate row / column by a number of pixels."""
        if axis == "column":
            new_order = (np.array(range(0, self.grid_tall)) - pixels) % self.grid_tall
            self.grid[:, idx] = self.grid[new_order, idx]
        else:
            new_order = (np.array(range(0, self.grid_width)) - pixels) % self.grid_width
            self.grid[idx, :] = self.grid[idx, new_order]


    def parse_input(self, proc: str) -> List[str]:
        """Split input procedure on newlines to return a list of instructions."""
        return [e.strip() for e in proc.split('\n') if e != '']


    def exec_instructions(self) -> int:
        """Execute instructions in loop and move accordingly."""
        instructions = self.parse_input(proc=self.proc)
        print(self.__repr__())

        for instruction in instructions:
            print(f"\n{instruction}:")
            tokens = instruction.split(' ')
            if tokens[0] == "rect":
                wide, tall = [int(token) for token in tokens[1].split('x')]
                self.add_rectangle(wide=wide, tall=tall)
            else:
                idx = int(tokens[2].split('=')[-1])
                pixels = int(tokens[4])
                self.rotate_axis(axis=tokens[1], idx=idx, pixels=pixels)

            print(self.__repr__())

        return sum(sum(np.char.count(self.grid, '#')))


test_proced = """rect 3x2
rotate column x=1 by 1
rotate row y=0 by 4
rotate column x=1 by 1"""


# Main ------------------------------------------------------------------------
def main() -> int:
    # Test puzzle input
    # input_proced = test_proced
    # InputScreen = Screen(wide=7, tall=3, proc=test_proced)


    # Final puzzle input
    with open("../data/puz_input_2016_d8_pt1.txt", 'r') as f:
        input_proced = f.read()

    InputScreen = Screen(wide=50, tall=6, proc=input_proced)
    lit_pixels = InputScreen.exec_instructions()
    print(lit_pixels)

    return 0



if __name__ == '__main__':
    sys.exit(main())
