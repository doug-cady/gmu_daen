"""
adventofcode.com
2016 Day 1: no time for a taxicab
"""

from typing import List


new_face = {
    'NR': 'E',
    'NL': 'W',
    'ER': 'S',
    'EL': 'N',
    'SR': 'W',
    'SL': 'E',
    'WR': 'N',
    'WL': 'S'
}

neg_face_turns = ['NL', 'ER', 'SR', 'WL']


def get_neg_mod(faceturn: str) -> int:
    return -1 if faceturn in neg_face_turns else 1


def walk(moves: List[str]) -> int:
    """ Walks along street grid and returns total taxicab distance """
    x = y = 0
    face = 'N'

    for move_id, move in enumerate(moves):
        turn = move[0]
        dist = int(move[1:])
        faceturn = face + turn

        if move_id % 2 == 0:
            x += dist * get_neg_mod(faceturn=faceturn)
        else:
            y += dist * get_neg_mod(faceturn=faceturn)

        face = new_face[faceturn]

    return abs(x) + abs(y)


assert walk("R2, L3".split(", ")) == 5
assert walk("R2, R2, R2".split(", ")) == 2
assert walk("R5, L5, R5, R3".split(", ")) == 12
assert walk("R3, R3, R3, R3".split(", ")) == 0

PATH = "L3, R2, L5, R1, L1, L2, L2, R1, R5, R1, L1, L2, R2, R4, L4, L3, L3, R5, L1, R3, L5, L2, R4, L5, R4, R2, L2, L1, R1, L3, L3, R2, R1, L4, L1, L1, R4, R5, R1, L2, L1, R188, R4, L3, R54, L4, R4, R74, R2, L4, R185, R1, R3, R5, L2, L3, R1, L1, L3, R3, R2, L3, L4, R1, L3, L5, L2, R2, L1, R2, R1, L4, R5, R4, L5, L5, L4, R5, R4, L5, L3, R4, R1, L5, L4, L3, R5, L5, L2, L4, R4, R4, R2, L1, L3, L2, R5, R4, L5, R1, R2, R5, L2, R4, R5, L2, L3, R3, L4, R3, L2, R1, R4, L5, R1, L5, L3, R4, L2, L2, L5, L5, R5, R2, L5, R1, L3, L2, L2, R3, L3, L4, R2, R3, L1, R2, L5, L3, R4, L4, R4, R3, L3, R1, L3, R5, L5, R1, R5, R3, L1"

print(walk(PATH.split(", ")))
