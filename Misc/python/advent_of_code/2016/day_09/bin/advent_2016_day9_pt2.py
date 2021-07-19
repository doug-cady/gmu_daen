"""
Advent of Code 2016
Day 9: Explosives in Cyberspace [Part 2]

url: https://adventofcode.com/2016/day/9

"""

import pytest
import sys
import numpy as np
from typing import List, Tuple


tests = {
    # 'ADVENT': 'ADVENT',
    # '(3x3)XYZ': 'XYZXYZXYZ',
    # 'A(1x5)BC': 'ABBBBBC',
    # 'A(2x2)BCD(2x2)EFG': 'ABCBCDEFEFG',
    # '(6x1)(1x3)A': 'AAA',
    # 'X(8x2)(3x3)ABCY': 'XABCABCABCABCABCABCY',
    '(27x12)(20x12)(13x14)(7x10)(1x12)A': 241920
}


def test_parse_instructions() -> None:
    for instr, ans in tests.items():
        if isinstance(ans, int):
            assert parse_instructions(instr) == ans
        else:
            assert parse_instructions(instr) == len(ans)


def decompress_marker(rem_proc: str) -> Tuple[int, int]:
    """Process marker like (3x2) to repeat next 3 characters 2 times.
        > Returns the length of repeated characters and the index skip value
    """
    skip_2_paren_lens = 2
    idx_add = 0
    rept_msg = rem_proc
    marker_len = 0
    print(f"\nMarker init: {rept_msg}")

    while True:
        rept_next_n, rest = rept_msg[1:].split('x', maxsplit=1)
        rept_next_n_int = int(rept_next_n)
        rept_num, rest = rest.split(')', maxsplit=1)
        rept_chars = rest[:rept_next_n_int]
        idx_add += skip_2_paren_lens + rept_msg[1:].index(')')
        rept_msg = ''.join([rept_chars] * int(rept_num))

        print(f"\nrept_next_n: {rept_next_n} | rept_num: {rept_num} | rept_chars: {rept_chars}")
        print(f"rest: {rest} | rept_msg: {rept_msg} | idx_add: {idx_add}")

        if '(' not in rept_chars:
            marker_len += len(rept_msg)

            if ('(' not in rest) | (len(rest) == rept_next_n_int):
                idx_add += rept_next_n_int
                break
            elif rest[rept_next_n_int] == '(':
                rept_msg = rest[rept_next_n_int:]
                idx_add -= skip_2_paren_lens + rept_msg[1:].index(')')
                print(f"- rept_msg: {rept_msg}")
            else:
                idx_add += rept_next_n_int
                break

        print(f"marker_len: {marker_len}")

    print(f"marker_len: {marker_len}")
    return marker_len, idx_add


def parse_instructions(proc: str) -> str:
    """Parse puzzle input and identify repeat markers to send to marker function."""
    decomp_msg = ''
    idx = 0
    decomp_len = 0
    print("\n---------------------------------------------------------")
    print("proc:", proc)
    print("len proc:", len(proc))

    while(idx < len(proc)):
        if proc[idx] == '(':
            len_rept_chars, idx_add = decompress_marker(rem_proc=proc[idx:])
            decomp_len += len_rept_chars
            idx += idx_add
            print("idx_add:", idx_add, "idx:", idx)
        else:
            decomp_len += 1
            idx += 1

    print("decomp_len:", decomp_len)
    return decomp_len



# Main ------------------------------------------------------------------------
def main() -> int:
    decomp_msg = test_parse_instructions()

    # Final puzzle input
    # with open("../data/puz_input_2016_d9_pt1.txt", 'r') as f:
    #     input_proc = f.read().strip(' ').strip('\n')

    # decomp_msg = parse_instructions(proc=input_proc)
    # print(f"Length: {len(decomp_msg):,}")

    return 0



if __name__ == '__main__':
    sys.exit(main())
