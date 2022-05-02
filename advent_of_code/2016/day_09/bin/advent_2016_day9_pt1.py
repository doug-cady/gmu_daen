"""
Advent of Code 2016
Day 9: Explosives in Cyberspace [Part 1]

url: https://adventofcode.com/2016/day/9

"""

import pytest
import sys
import numpy as np
from typing import List, Tuple


tests = {
    'ADVENT': 'ADVENT',
    'A(1x5)BC': 'ABBBBBC',
    'A(2x2)BCD(2x2)EFG': 'ABCBCDEFEFG',
    '(6x1)(1x3)A': '(1x3)A',
    'X(8x2)(3x3)ABCY': 'X(3x3)ABC(3x3)ABCY'
}


def test_parse_instructions() -> None:
    for instr, ans in tests.items():
        assert parse_instructions(instr) == ans


def decompress_marker(rem_proc: str) -> Tuple[str, int]:
    """Process marker like (3x2) to repeat next 3 characters 2 times.
        > Returns the repeated characters and the index skip value
    """
    rept_next_n, rest = rem_proc.split('x', maxsplit=1)
    rept_num, rest = rest.split(')', maxsplit=1)
    rept_chars = rest[:int(rept_next_n)]

    skip_2_parens_len = 2
    idx_add = skip_2_parens_len + rem_proc.index(')') + int(rept_next_n)

    return ''.join([rept_chars] * int(rept_num)), idx_add


def parse_instructions(proc: str) -> str:
    """Parse puzzle input and identify repeat markers to send to marker function."""
    decomp_msg = ''
    idx = 0

    while(idx < len(proc)):
        if proc[idx] == '(':
            rept_chars, idx_add = decompress_marker(rem_proc=proc[idx + 1:])
            decomp_msg = decomp_msg + rept_chars
            idx += idx_add
        else:
            decomp_msg = decomp_msg + proc[idx]
            idx += 1

    return decomp_msg



# Main ------------------------------------------------------------------------
def main() -> int:
    test_parse_instructions()

    # Final puzzle input
    with open("../data/puz_input_2016_d9_pt1.txt", 'r') as f:
        input_proc = f.read().strip(' ').strip('\n')

    decomp_msg = parse_instructions(proc=input_proc)
    # print(f"Decompressed message: {decomp_msg}")
    print(f"Length: {len(decomp_msg):,}")

    return 0



if __name__ == '__main__':
    sys.exit(main())
