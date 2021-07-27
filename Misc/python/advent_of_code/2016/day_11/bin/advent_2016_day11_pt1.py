"""
Advent of Code 2016
Day 11: Radioisotope Thermoelectric Generators [Part 1]

url: https://adventofcode.com/2016/day/11

"""

import sys
import numpy as np
from typing import List


def test_diagram() -> None:
    init_diagram = np.array([['F1', 'E ', '. ', 'HM', '. ', 'LM'],
                             ['F2', '. ', 'HG', '. ', '. ', '. '],
                             ['F3', '. ', '. ', '. ', 'LG', '. '],
                             ['F4', '. ', '. ', '. ', '. ', '. ']])

    test_class_inst = RTG(init_diagram=init_diagram)
    print(test_class_inst)
    test_class_inst.move()
    # print(test_class_inst)


class RTG:
    def __init__(self, init_diagram: np.array) -> None:
        self.diagram = init_diagram
        self.elev_row = len(init_diagram) - 1
        self.chips_mask = [3, 5]
        self.rtg_mask = [2, 4]
        self.hyd_mask = [2, 3]
        self.lit_mask = [4, 5]


    def __repr__(self) -> str:
        return '\n'.join('  ' + ' '.join(val for val in row) for row in self.diagram[::-1])


    def get_elects(self, mask: List[int]) -> List[str]:
        """Apply bit mask to get RTGs, microchips, or element based columns electronics."""
        return [val for row in self.diagram[:, mask] for val in row if val != '. ']


    def move(self) -> None:
        print(self.get_elects(self.hyd_mask))
        print(self.get_elects(self.lit_mask))



# Main ------------------------------------------------------------------------
def main() -> int:
    test_diagram()

    # Final puzzle input
    # with open("../data/puz_input_2016_d11_pt1.txt", 'r') as f:
    #     puz_input = [line for line in f.read().split('\n') if line != '']



    return 0


if __name__ == '__main__':
    sys.exit(main())
