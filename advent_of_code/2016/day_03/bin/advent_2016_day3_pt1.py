"""
Solving Advent of Code 2016 day 3 problem
Squares with Three Sides
"""

import pytest
import sys
import numpy as np
from typing import List


def test_is_valid() -> None:
    tests = [
        [3, 4, 5, True],
        [3, 3, 5, True],
        [3, 2, 5, False],
        [30, 4, 5, False],
        [5, 10, 25, False],
    ]
    for test in tests:
        assert is_triangle_possible(*test[:3]) == test[3]


def is_triangle_possible(x: int, y: int, z: int) -> bool:
    """
    Determines if a given 3 edge triangle is possible. Sum of any 2 sides must
    be greater than the remaining side.

    Ex: 5 10 25 is NOT possible because 5 + 10 is not larger than 25

    """
    test_sides = [x + y > z, x + z > y, y + z > x, False]
    return test_sides.index(False) == 3


def count_possible_triangles(intext: str) -> int:
    """Count how many triangles are possible from input text."""
    triangles = [[int(edge.strip())
                  for edge in line.strip().split(' ') if edge != '']
                 for line in intext.split('\n')]
    return sum(is_triangle_possible(*triangle) for triangle in triangles)


# Main ------------------------------------------------------------------------
def main() -> int:
    # Final puzzle input
    with open("../data/puz_input_2016_d3_pt1.txt", 'r') as f:
        puz_input_text = f.read().strip('\n')

    possible_triangles = count_possible_triangles(intext=puz_input_text)

    with open("../results/puz_answer_2016_d3.txt", 'w') as o:
        o.write(f"Part 1 answer: {possible_triangles:,}")

    return 0



if __name__ == '__main__':
    sys.exit(main())
