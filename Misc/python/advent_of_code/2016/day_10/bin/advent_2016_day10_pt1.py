"""
Advent of Code 2016
Day 10: Balance Bots [Part 1]

url: https://adventofcode.com/2016/day/10

"""

import pytest
import sys
import numpy as np
from typing import List, Tuple


tests = {
    'ADVENT': 'ADVENT',
    '(3x3)XYZ': 'XYZXYZXYZ',
    'A(1x5)BC': 'ABBBBBC',
    'A(2x2)BCD(2x2)EFG': 'ABCBCDEFEFG',
    '(6x1)(1x3)A': 'AAA',
    'X(8x2)(3x3)ABCY': 'XABCABCABCABCABCABCY',
    '(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN': 445,
    '(27x12)(20x12)(13x14)(7x10)(1x12)A': 241920
}


def test_parse_instructions() -> None:
    for instr, ans in tests.items():
        if isinstance(ans, int):
            assert parse_instructions(instr) == ans
        else:
            assert parse_instructions(instr) == len(ans)


def decompress(rem_proc: str) -> Tuple[str, int]:
    """Decompress message starting at identified marker and return decompressed message."""
    idx_add = 0
    skip_2_paren_len = 2
    btw_parens_len = rem_proc[1:].index(')')

    rept_next_n, rest = rem_proc[1:].split('x', maxsplit=1)
    rept_next_n_int = int(rept_next_n)
    rept_n_times, rest = rest.split(')', maxsplit=1)
    rept_chars = rest[:rept_next_n_int]
    idx_add += skip_2_paren_len + btw_parens_len

    rept_msg = ''.join([rept_chars] * int(rept_n_times))
    after_marker_msg = rem_proc[idx_add + rept_next_n_int:]

    if '(' in rept_msg:
        return rept_msg + after_marker_msg, 0
    else:
        return after_marker_msg, len(rept_msg)


def parse_instructions(proc: str) -> str:
    """Parse puzzle input and identify repeat markers to send to decompress function."""
    msg = proc
    idx = 0
    final_len = 0

    while len(msg) > 0:
        if msg[idx] == '(':
            msg, decomp_len = decompress(rem_proc=msg[idx:])
            final_len += decomp_len
            idx = 0
        else:
            final_len += 1impo
            msg = msg[1:]

    print("final_len:", final_len)
    return final_len



# Main ------------------------------------------------------------------------
def main() -> int:
    decomp_msg = test_parse_instructions()

    # Final puzzle input
    # with open("../data/puz_input_2016_d9_pt1.txt", 'r') as f:
    #     input_proc = f.read().strip(' ').strip('\n')

    # decomp_len = parse_instructions(proc=input_proc)
    # print(f"Length: {decomp_len:,}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
