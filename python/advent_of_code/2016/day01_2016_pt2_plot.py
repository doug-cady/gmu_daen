"""
adventofcode.com
2016 Day 1: no time for a taxicab
Part 2 (w/ matplotlib plot)
"""

from typing import NamedTuple, List
import matplotlib.pyplot as plt


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


def walk_pt2(moves: List[str]) -> set:
    """ Walks along street grid and returns total taxicab distance """
    x = y = 0
    face = 'N'
    visit_list = [XY(0, 0)]
    visited = set(visit_list)

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
        visit_list.append(XY(x, y))

        if len(visit_twice) >= 1:
            print(visit_twice)
            break
        else:
            visited = visited.union(new_locs)


    return visit_list, visit_twice.pop()

# assert walk_pt2("R8, R4, R4, R8".split(", ")) == 4


def plot_path(xs: List[int], ys: List[int], int_pt: tuple) -> None:
    """ Plot path taken by person until intersection happens """
    int_x = int_pt.x
    int_y = int_pt.y

    with plt.style.context('ggplot'):
        plt.figure(figsize=(10, 10))
        plt.plot(xs, ys, 'b', alpha=.5)

        plt.plot(0, 0, 'r*', alpha=.7)
        plt.plot(int_x, int_y, 'rX', alpha=.7)

        plt.title("Advent of Code 2016 day 1 part 2: Plotting taxicab path")

        plt.annotate(
            text="Start search at (0, 0)",
            xy=(2, 2),
            xytext=(10, 10),
            arrowprops={
                'facecolor': 'black',
                'shrink': 0.1,
                'headlength': 7
            }
        )

        plt.annotate(
            text=f"First point visited twice ({int_x}, {int_y})",
            xy=(int_x - 2, int_y + 2),
            xytext=(int_x - 11, int_y + 11),
            arrowprops={
                'facecolor': 'black',
                'shrink': 0.1,
                'headlength': 7
            },
            ha='right'
        )

        plt.grid(False)

        plt.savefig('adventofcode_2016_1_pt2_plot.jpg')
        plt.show()



if __name__ == '__main__':
    PATH = "L3, R2, L5, R1, L1, L2, L2, R1, R5, R1, L1, L2, R2, R4, L4, L3, L3, R5, L1, R3, L5, L2, R4, L5, R4, R2, L2, L1, R1, L3, L3, R2, R1, L4, L1, L1, R4, R5, R1, L2, L1, R188, R4, L3, R54, L4, R4, R74, R2, L4, R185, R1, R3, R5, L2, L3, R1, L1, L3, R3, R2, L3, L4, R1, L3, L5, L2, R2, L1, R2, R1, L4, R5, R4, L5, L5, L4, R5, R4, L5, L3, R4, R1, L5, L4, L3, R5, L5, L2, L4, R4, R4, R2, L1, L3, L2, R5, R4, L5, R1, R2, R5, L2, R4, R5, L2, L3, R3, L4, R3, L2, R1, R4, L5, R1, L5, L3, R4, L2, L2, L5, L5, R5, R2, L5, R1, L3, L2, L2, R3, L3, L4, R2, R3, L1, R2, L5, L3, R4, L4, R4, R3, L3, R1, L3, R5, L5, R1, R5, R3, L1"

    pts_visited, int_pt = walk_pt2(PATH.split(", "))

    xs = [pt.x for pt in pts_visited]
    ys = [pt.y for pt in pts_visited]

    plot_path(xs=xs, ys=ys, int_pt=int_pt)
