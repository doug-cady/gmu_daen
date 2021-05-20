"""
adventofcode.com
2016 Day 1: no time for a taxicab
Part 2
"""

from typing import NamedTuple, List


class XY(NamedTuple):
    x: int
    y: int


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


def walk2(moves: List[str]) -> int:
    """ Walks along street grid and returns total taxicab distance """
    x = y = 0
    face = 'N'
    visited = set([XY(0, 0)])

    for move_id, move in enumerate(moves):
        turn = move[0]
        dist = int(move[1:])
        faceturn = face + turn

        mod = get_neg_mod(faceturn=faceturn)
        dist_chg = dist * mod

        if move_id % 2 == 0:
            new_locs = set(XY(chg, y) for chg in range(x+mod, x+dist_chg+mod, mod))
            x += dist_chg
        else:
            new_locs = set(XY(x, chg) for chg in range(y+mod, y+dist_chg+mod, mod))
            y += dist_chg

        face = new_face[faceturn]

        visit_twice = visited.intersection(new_locs)

        if len(visit_twice) >= 1:
            print("\n", visit_twice)
            break
        else:
            visited = visited.union(new_locs)

    if len(visit_twice) == 1:
        loc = visit_twice.pop()
        return abs(loc.x) + abs(loc.y)
    else:
        return visit_twice


# assert walk2("R8, R4, R4, R8".split(", ")) == 4

PATH = "L3, R2, L5, R1, L1, L2, L2, R1, R5, R1, L1, L2, R2, R4, L4, L3, L3, R5, L1, R3, L5, L2, R4, L5, R4, R2, L2, L1, R1, L3, L3, R2, R1, L4, L1, L1, R4, R5, R1, L2, L1, R188, R4, L3, R54, L4, R4, R74, R2, L4, R185, R1, R3, R5, L2, L3, R1, L1, L3, R3, R2, L3, L4, R1, L3, L5, L2, R2, L1, R2, R1, L4, R5, R4, L5, L5, L4, R5, R4, L5, L3, R4, R1, L5, L4, L3, R5, L5, L2, L4, R4, R4, R2, L1, L3, L2, R5, R4, L5, R1, R2, R5, L2, R4, R5, L2, L3, R3, L4, R3, L2, R1, R4, L5, R1, L5, L3, R4, L2, L2, L5, L5, R5, R2, L5, R1, L3, L2, L2, R3, L3, L4, R2, R3, L1, R2, L5, L3, R4, L4, R4, R3, L3, R1, L3, R5, L5, R1, R5, R3, L1"

print(walk2(PATH.split(", ")))
