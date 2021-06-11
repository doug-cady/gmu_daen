"""
Solving Advent of Code 2016 day 2 problem
Bathroom Security
"""

import pytest
import sys
import numpy as np
from typing import List


class Point():
    def __init__(self,
                 keyrows: int = 3,
                 nums: int = 9,
                 beg_rowcol: List[int] = [1, 1],
                 proc: str = ""):
        self.keyrows = keyrows
        self.row = beg_rowcol[0]
        self.col = beg_rowcol[1]
        self.proc_list = self.parse_input(proc=proc)
        self.keypad = self.make_beg_keypad(nums=nums)


    def parse_input(self, proc: str) -> List[str]:
        """Split input procedure on newlines to return a list of instructions."""
        return [e.strip() for e in proc.split('\n') if e != '']


    def make_beg_keypad(self, nums: int) -> List[List[int]]:
        """Creates a matrix of n consecutive numbers across rows and returns a matrix."""
        keypad_nums = list(range(1, nums + 1))
        beg_keypad = [keypad_nums[i:i + self.keyrows]
                      for i in range(0, len(keypad_nums), self.keyrows)]
        return beg_keypad


    def move(self, instr: str) -> None:
        """Updates rows and cols by processing next instruction."""
        dirs = {
            'U': np.array([-1, 0]),
            'D': np.array([1, 0]),
            'R': np.array([0, 1]),
            'L': np.array([0, -1]),
        }
        next_move = np.array([self.row, self.col]) + dirs[instr]

        if self.is_valid(next_move=next_move):
            self.row, self.col = next_move


    def is_valid(self, next_move: np.array) -> bool:
        """Identifies if next button instruction is a valid move within keypad dims."""
        row, col = next_move
        if (0 <= row <= self.keyrows - 1) & (0 <= col <= self.keyrows - 1):
            return True
        else:
            return False


    def exec_instructions(self) -> str:
        """Execute instructions in loop and move accordingly."""
        bathroom_code = ""

        for line in self.proc_list:
            for instr in line:
                self.move(instr=instr)

            bathroom_code += str(self.keypad[self.row][self.col])

        return bathroom_code


test_proced = """ULL
RRDDD
LURDL
UUUUD"""


# Main ------------------------------------------------------------------------
def main() -> int:
    # Test puzzle input
    # input_proced = test_proced

    # Final puzzle input
    with open("../data/puz_input_2016_d2_pt1.txt", 'r') as f:
        input_proced = f.read()

    InputPoint = Point(keyrows=3, nums=9, beg_rowcol=[1, 1], proc=input_proced)
    code = InputPoint.exec_instructions()
    print(code)

    return 0



if __name__ == '__main__':
    sys.exit(main())
