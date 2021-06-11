"""
Solving Advent of Code 2016 day 2 problem
Bathroom Security (Part 2)
"""

import sys
import numpy as np
from typing import List
import string


class Point():
    def __init__(self,
                 keyrows: int = 3,
                 beg_rowcol: List[int] = [1, 1],
                 proc: str = ""):
        self.keyrows = keyrows
        self.row = beg_rowcol[0]
        self.col = beg_rowcol[1]
        self.proc_list = self.parse_input(proc=proc)
        self.keypad = self.make_beg_keypad()


    def parse_input(self, proc: str) -> List[str]:
        """Split input procedure on newlines to return a list of instructions."""
        return [e.strip() for e in proc.split('\n') if e != '']


    def make_beg_keypad(self) -> List[List[str]]:
        """Creates a matrix of n consecutive numbers across rows and returns a matrix."""
        beg_keypad = [
            ['',  '',  '1',  '',  ''],
            ['',  '2', '3', '4',  ''],
            ['5', '6', '7', '8', '9'],
            ['',  'A', 'B', 'C',  ''],
            ['',  '',  'D',  '',  ''],
        ]

        return beg_keypad


    def move(self, instr: str) -> None:
        """Updates row and col by processing next instruction."""
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
        next_row, next_col = next_move
        left_edge = 0
        right_edge = self.keyrows - 1

        if ((left_edge <= next_row <= right_edge) &
            (left_edge <= next_col <= right_edge)):
            if self.keypad[next_row][next_col] != '':
                return True

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


def main() -> int:
    # Test puzzle input
    # input_proced = test_proced

    # Final puzzle input
    with open("../data/puz_input_2016_d2_pt1.txt", 'r') as f:
        input_proced = f.read()

    TestPoint = Point(keyrows=5, beg_rowcol=[2, 0], proc=input_proced)

    code = TestPoint.exec_instructions()
    print(code)

    return 0


if __name__ == '__main__':
    sys.exit(main())
