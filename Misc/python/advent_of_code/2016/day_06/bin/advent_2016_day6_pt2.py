"""
Advent of Code 2016
Day 6: Signals and Noise

[Part 2]
Of course, that would be the message - if you hadn't agreed to use a modified
repetition code instead.

In this modified code, the sender instead transmits what looks like random
data, but for each character, the character they actually want to send is
slightly less likely than the others. Even after signal-jamming noise, you
can look at the letter distributions in each column and choose the least
common letter to reconstruct the original message.

In the above example, the least common character in the first column is a;
in the second, d, and so on. Repeating this process for the remaining characters
produces the original message, advent.

Given the recording in your puzzle input and this new decoding methodology,
what is the original message that Santa is trying to send?
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


def test_get_least_common_letters() -> None:
    transposed_msg = transpose_message(puz_input=test)
    corrected_msg = get_least_common_letters(transposed_msg=transposed_msg)
    assert corrected_msg == "advent"


def get_least_common_letters(transposed_msg: List[List[str]]) -> str:
    """Get least common letters from each column and return error-corrected message."""
    corrected_msg = [[letter[0][0] for letter in Counter(msg).most_common()][-1]
                     for msg in transposed_msg]
    return ''.join(corrected_msg)


def transpose_message(puz_input: str) -> str:
    """Transpose message to prepare for finding least common letter."""
    return [list(row) for row in zip(*puz_input.split('\n'))]


# Main ------------------------------------------------------------------------
def main() -> int:
    # Final puzzle input
    with open("../data/puz_input_2016_d6_pt1.txt", 'r') as f:
        puz_input = f.read().strip('\n')

    transposed_msg = transpose_message(puz_input=puz_input)
    corrected_msg = get_least_common_letters(transposed_msg=transposed_msg)

    with open("../results/puz_answer_2016_d6.txt", 'a') as out:
        out.write(f"\nPart 2 answer: {corrected_msg}")

    print(f"Complete. Answer: {corrected_msg}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
