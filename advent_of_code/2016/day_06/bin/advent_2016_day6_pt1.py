"""
Advent of Code 2016
Day 6: Signals and Noise

[Part 1]
In this model, the same message is sent repeatedly. You've recorded the
repeating message signal (your puzzle input), but the data seems quite corrupted
 - almost too badly to recover. Almost.

All you need to do is figure out which character is most frequent for each
position. For example, suppose you had recorded the following messages:

eedadn
drvtee
eandsr
raavrd
atevrs
tsrnev
sdttsa
rasrtv
nssdts
ntnada
svetve
tesnvt
vntsnd
vrdear
dvrsen
enarar

The most common character in the first column is e; in the second, a; in the
third, s, and so on. Combining these characters returns the error-corrected
message, easter.
"""


import pytest
import sys
from collections import Counter
from typing import List


test = """eedadn
drvtee
eandsr
raavrd
atevrs
tsrnev
sdttsa
rasrtv
nssdts
ntnada
svetve
tesnvt
vntsnd
vrdear
dvrsen
enarar"""


def test_get_most_common_letters() -> None:
    transposed_msg = transpose_message(puz_input=test)
    corrected_msg = get_most_common_letters(transposed_msg=transposed_msg)
    assert corrected_msg == "easter"


def get_most_common_letters(transposed_msg: List[List[str]]) -> str:
    """Get most common letters from each column and return error-corrected message."""
    corrected_msg = [[letter[0][0] for letter in Counter(msg).most_common(1)][0]
                     for msg in transposed_msg]
    return ''.join(corrected_msg)


def transpose_message(puz_input: str) -> str:
    """Transpose message to prepare for finding most common letter."""
    return [list(row) for row in zip(*puz_input.split('\n'))]


# Main ------------------------------------------------------------------------
def main() -> int:
    # Final puzzle input
    with open("../data/puz_input_2016_d6_pt1.txt", 'r') as f:
        puz_input = f.read().strip('\n')

    transposed_msg = transpose_message(puz_input=puz_input)
    corrected_msg = get_most_common_letters(transposed_msg=transposed_msg)

    with open("../results/puz_answer_2016_d6.txt", 'w') as out:
        out.write(f"Part 1 answer: {corrected_msg}")

    print(f"Complete. Answer: {corrected_msg}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
