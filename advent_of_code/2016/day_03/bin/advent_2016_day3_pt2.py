"""
Solving Advent of Code 2016 day 3 problem
Squares with Three Sides (Part 2)
"""

import pytest
import sys
import numpy as np
from typing import List



def test_transpose_triangles() -> None:
    test1 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    exp_result1 = [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
    assert transpose_triangles(test1) == exp_result1

    test2 = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
              [10, 11, 12], [13, 14, 15], [16, 17, 18]]
    exp_result2 = [[1, 4, 7], [2, 5, 8], [3, 6, 9],
                    [10, 13, 16], [11, 14, 17], [12, 15, 18]]
    assert transpose_triangles(test2) == exp_result2



test_triangles = """  330  143  338
  769  547   83
  930  625  317
  669  866  147
   15  881  210
  662   15   70"""

# [tri.strip(' ') for tri in test_triangles.strip('\n').split('\n')]

# triangles = [[int(edge.strip()) for edge in line.strip().split(' ') if edge != '']
#              for line in test_triangles.split('\n')]
# [list(map(list, zip(*triangles[i:i + 3]))) for i in range(0, len(triangles), 3)]

# list(map(list, zip(*triangles)))

# vert_tris = []
# for tri1, tri2, tri3 in zip(triangles, triangles[1:], triangles[2:]):
#     ([[l1_t1, l1_t2, l1_t3],
#       [l2_t1, l2_t2, l2_t3],
#       [l3_t1, l3_t2, l3_t3]] = [*tri1, *tri2, *tri3])

#     (vert_tris.append([[l1_t1, l2_t1, l3_t1],
#                        [l1_t2, l2_t2, l3_t2],
#                        [l1_t3, l2_t3, l3_t3]]))
# print(vert_tris)

# vert_tris = [[li1_ti1, li2_ti1, li3_ti1], [li1_ti2, li2_ti2, li3_ti2], [li1_ti3, li2_ti3, li3_ti3]
#         for [[li1_ti1, li1_ti2, li1_ti3], [li2_ti1, li2_ti2, li2_ti3], [li3_ti1, li3_ti2, li3_ti3]]
#     in zip(triangles, triangles[1:], triangles[2:])]


def is_triangle_possible(x: int, y: int, z: int) -> bool:
    """
    Determines if a given 3 edge triangle is possible. Sum of any 2 sides must
    be greater than the remaining side.

    Ex: 5 10 25 is NOT possible because 5 + 10 is not larger than 25

    """
    test_sides = [x + y > z, x + z > y, y + z > x, False]
    return test_sides.index(False) == 3


def transpose_triangles(triangles: List[List[int]]) -> List[List[int]]:
    """Transpose triangle list from horizontal to vertical sets."""
    return [list(tris) for i in range(0, len(triangles), 3)
            for tris in zip(*triangles[i:i + 3])]


def parse_input(intext: str) -> List[List[int]]:
    """Parse input text into original horizontal triangle sets."""
    return [[int(edge.strip()) for edge in line.strip().split(' ') if edge != '']
            for line in intext.split('\n')]



# Main ------------------------------------------------------------------------
def main() -> int:
    # Final puzzle input
    with open("../data/puz_input_2016_d3_pt1.txt", 'r') as f:
        puz_input_text = f.read().strip('\n')

    triangles = parse_input(intext=puz_input_text)
    vert_triangles = transpose_triangles(triangles=triangles)
    possible_triangles = sum(is_triangle_possible(*triangle)
                             for triangle in vert_triangles)

    # print(possible_triangles)  # 1649

    with open("../results/puz_answer_2016_d3.txt", 'a') as o:
        o.write(f"\nPart 2 answer: {possible_triangles:,}")

    return 0



if __name__ == '__main__':
    sys.exit(main())
