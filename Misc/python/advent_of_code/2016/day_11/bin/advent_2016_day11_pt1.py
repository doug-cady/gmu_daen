"""
Advent of Code 2016
Day 11: Radioisotope Thermoelectric Generators [Part 1]

url: https://adventofcode.com/2016/day/11

"""

import sys
import itertools
import numpy as np
from typing import List, NamedTuple, Dict


# class Component(NamedTuple):
#     is_rtg: bool
#     elem: str
#     col: int


class Move(NamedTuple):
    num: int
    item_1: str
    item_2: str
    from_floor: str
    to_floor: str



def test_diagram() -> None:
    # test_components = {
    #     'HG': Component(is_rtg=True,  elem='Hydrogen', col=2),
    #     'HM': Component(is_rtg=False, elem='Hydrogen', col=3),
    #     'LG': Component(is_rtg=True,  elem='Lithium',  col=4),
    #     'LM': Component(is_rtg=False, elem='Lithium',  col=5)
    # }

    init_diagram = np.array([['F1', 'E ', ' . ', 'H_M', ' . ', 'L_M'],
                             ['F2', '. ', 'H_G', ' . ', ' . ', ' . '],
                             ['F3', '. ', ' . ', ' . ', 'L_G', ' . '],
                             ['F4', '. ', ' . ', ' . ', ' . ', ' . ']])
    item_idx = ['floor', 'elev', 'H_G', 'H_M', 'L_G', 'L_M']

    test_class_inst = RTG(init_diagram=init_diagram, item_idx=item_idx)
    # print(test_class_inst)
    test_class_inst.pick_move()
    # print(test_class_inst)



class RTG:
    def __init__(self, init_diagram: np.array, item_idx: List[str]) -> None:
        self.diagram = init_diagram
        self.item_idx = item_idx
        # self.components = components
        self.end_row = len(init_diagram) - 1
        self.elev_row = 0
        self.pot_move_items = []
        self.move_rows = [1]


    def __repr__(self) -> str:
        return '\n'.join('  ' + ' '.join(val for val in row) for row in self.diagram[::-1])


    def get_row_items(self, row: int) -> List[str]:
        """Get all RTGs, microchips, or element based column electronics from a given row."""
        return [val for val in self.diagram[row, 2:] if val != ' . ']


    def get_all_row_combos(self, row_items: List[str]) -> List[str]:
        """Get all row permutations of items in a row including single items."""
        combos = list(itertools.combinations(row_items, 2))
        return [[first, second] for first, second in combos] + row_items


    def same_elems(self, item_1: str, item_2: str) -> bool:
        """Check if items 1 and 2 share the same element (ie Hydrogen)."""
        return item_1.split('_')[0] == item_2.split('_')[0]


    def same_type(self, item_1: str, item_2: str) -> bool:
        """Check if items 1 and 2 are the same type (ie both Microchip or both RTG)."""
        return item_1.split('_')[1] == item_2.split('_')[1]


    def compatible_rtg(self, elev_list: List[str], move_row_item: str) -> bool:
        """Check if move row has an compatible RTG that would allow a microchip move."""
        print(f"elev_list: {elev_list}")
        print(f"move_row_item: {move_row_item}")
        for item in elev_list:
            if not self.same_elems(item_1=item, item_2=move_row_item):
                return False
        else:
            return True


    def init_move(self) -> None:
        """Initialize elevator and move row items before picking next move."""
        if self.elev_row == 0:
            self.move_rows = [1]
        elif self.elev_row == self.end_row:
            self.move_rows = [self.end_row]
        else:
            self.move_rows = [self.elev_row + 1, self.elev_row - 1]

        elev_items = self.get_row_items(row=self.elev_row)
        self.pot_move_items = self.get_all_row_combos(row_items=elev_items)

        self.move_row_items = {move_row: self.get_row_items(row=move_row)
                               for move_row in self.move_rows}


    def pick_move(self) -> None:
        self.init_move()
        past_moves = []
        trial_moves = []

        for trial, elev_item in enumerate(self.pot_move_items):
            for move_row, move_row_item in self.move_row_items.items():

                print(self.__repr__)
                print(f"\ntrial: {trial} | elev_row: {self.elev_row}")
                print(f"elev_item: {elev_item}")
                print(f"move_row: {move_row} | move_row_item: {move_row_item}")

                # Does move row have an incompatible RTG to fry a Microchip?
                if not self.compatible_rtg(elev_list=elev_item, move_row_item=move_row_item):
                    continue

                # Does move row have a compatible item to match with?
                # if self.compatible_rtg(elev_list=elev_item, move_row_item=move_row_item):


                self.init_move()


# Main ------------------------------------------------------------------------
def main() -> int:
    test_diagram()

    # Final puzzle input
    # with open("../data/puz_input_2016_d11_pt1.txt", 'r') as f:
    #     puz_input = [line for line in f.read().split('\n') if line != '']



    return 0


if __name__ == '__main__':
    sys.exit(main())
