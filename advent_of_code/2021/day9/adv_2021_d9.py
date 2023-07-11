"""
Advent of Code 2021
Day 9: Smoke Basin

June 2, 2023

"""

from typing import List, Dict, NamedTuple
import numpy as np
from collections import defaultdict


EX_INPUT_1 = """2199943210
3987894921
9856789892
8767896789
9899965678"""


# --------------------------------------------------------------------------------------------------
# Part 1: Count number of low points in grid - where all adjacent points have higher values
# --------------------------------------------------------------------------------------------------
def parse_puz_input(puz: str) -> np.array:
    return np.array([[int(num) for num in line] for line in puz.strip().split("\n")])


def find_low_point_risk(heightmap: np.array) -> int:
    """Identify low points in hydrothemal vent grids and return their risk level."""
    rows, cols = heightmap.shape
    low_points = []
    found_low_pt = False

    for row in range(rows):
        for col in range(cols):
            if found_low_pt:
                found_low_pt = False
                continue

            val = heightmap[row, col]
            possible_adj_idxs = [[row - 1, col], [row, col - 1], [row + 1, col], [row, col + 1]]
            min_adj_vals = min([heightmap[row_idx, col_idx] 
                                for row_idx, col_idx in possible_adj_idxs
                                if (rows > row_idx >= 0) & (cols > col_idx >= 0)])
            if val < min_adj_vals:
                low_points.append(val)
                found_low_pt = True

    return sum(low_points) + len(low_points)


ex_heightmap = parse_puz_input(puz=EX_INPUT_1)
low_pt_risk = find_low_point_risk(heightmap=ex_heightmap)
assert low_pt_risk == 15


# Part 1 puzzle input
puz_input = open('adv_2021_d9_input.txt').read()
puz_heightmap = parse_puz_input(puz=puz_input)
print("Part 1:", find_low_point_risk(heightmap=puz_heightmap))


# --------------------------------------------------------------------------------------------------
# Part 2: Decode patterns for each signal and sum output values
# --------------------------------------------------------------------------------------------------
class Point(NamedTuple):
    row: int
    col: int
    val: int

def find_low_points(heightmap: np.array) -> (np.array, set):
    """Identify basin areas where values 'flow' downward towards low point."""
    rows, cols = heightmap.shape
    low_pt_tracker = np.zeros_like(heightmap)
    low_pts_set = set()
    found_low_pt = False

    for row in range(rows):
        for col in range(cols):
            if found_low_pt:
                found_low_pt = False
                continue

            val = heightmap[row, col]
            possible_adj_idxs = [[row - 1, col], [row, col - 1], [row + 1, col], [row, col + 1]]
            min_adj_vals = min([heightmap[row_idx, col_idx] 
                                for row_idx, col_idx in possible_adj_idxs
                                if (rows > row_idx >= 0) & (cols > col_idx >= 0)])
            if val < min_adj_vals:
                low_pt_tracker[row, col] = 1
                low_pts_set.add(Point(row=row, col=col, val=val))
                found_low_pt = True

    return low_pt_tracker, low_pts_set


def _get_adj_points(pt: Point, rows: int, cols: int, heightmap: np.array,
                    visited_pts: set) -> List[Point]:
    possible_adj_idxs = [[pt.row - 1, pt.col], [pt.row, pt.col - 1], 
                         [pt.row + 1, pt.col], [pt.row, pt.col + 1]]
    adj_idxs = [[row, col] for row, col in possible_adj_idxs
                if (rows > row >= 0) & (cols > col >= 0)]

    adj_points = [Point(row, col, heightmap[row, col]) for row, col in adj_idxs
                  if (heightmap[row, col] != 9)]

    return [pt for pt in adj_points if pt not in visited_pts]


def _get_min_adj_point(adj_points: List[Point]) -> Point:
    min_adj = None

    for pt in adj_points:
        if min_adj is None:
            min_adj = pt
        elif pt.val < min_adj.val:
            min_adj = pt

    return min_adj


def find_basins(heightmap: np.array, low_pts_array: np.array, low_pts_set: set) -> int:
    """Loop over low points and find all basin points around each."""
    rows, cols = heightmap.shape
    found_low_pt = False
    basins = {}
    walk_path = []

    for low_pt in low_pts_set:
        basins[f"{low_pt.row}_{low_pt.col}"] = [low_pt]
        walk_path.append(low_pt)
        cur_pt = low_pt
        all_adj_points = set([low_pt])

        while True:
            adj_points = _get_adj_points(pt=cur_pt, rows=rows, cols=cols, heightmap=heightmap,
                                         visited_pts=basins[f"{low_pt.row}_{low_pt.col}"])
            if len(adj_points) == 0:
                cur_pt = walk_path.pop()
                continue
            else:
                all_adj_points = all_adj_points.union(set(adj_points))

            if len(all_adj_points) == 0:
                break

            min_adj_pt = _get_min_adj_point(adj_points=adj_points)
            basins[f"{low_pt.row}_{low_pt.col}"].append(min_adj_pt)
            walk_path.append(min_adj_pt)

            all_adj_points = all_adj_points - set([cur_pt, min_adj_pt])
            cur_pt = min_adj_pt

        print(basins)
        # print(basins[f"{low_pt.row}_{low_pt.col}"])
        print()

        import pdb; pdb.set_trace()
    
    return basins


low_pts_array, low_pts_set = find_low_points(heightmap=ex_heightmap)
# print(low_pts_array)
# print(low_pts_set)

final_basins = find_basins(heightmap=ex_heightmap, low_pts_array=low_pts_array,
                           low_pts_set=low_pts_set)
