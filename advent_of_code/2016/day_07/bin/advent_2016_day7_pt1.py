"""
Advent of Code 2016
Day 7: Internet Protocol Version 7

[Part 1]
While snooping around the local network of EBHQ, you compile a list of IP
addresses (they're IPv7, of course; IPv6 is much too limited). You'd like to
figure out which IPs support TLS (transport-layer snooping).

An IP supports TLS if it has an Autonomous Bridge Bypass Annotation, or ABBA.
An ABBA is any four-character sequence which consists of a pair of two different
characters followed by the reverse of that pair, such as xyyx or abba. However,
the IP also must not have an ABBA within any hypernet sequences, which are
contained by square brackets.

For example:

- abba[mnop]qrst supports TLS (abba outside square brackets).
- abcd[bddb]xyyx does not support TLS (bddb is within square brackets, even
    though xyyx is outside square brackets).
- aaaa[qwer]tyui does not support TLS (aaaa is invalid; the interior
    characters must be different).
- ioxxoj[asdfgh]zxcvbn supports TLS (oxxo is outside square brackets,
    even though it's within a larger string).

How many IPs in your puzzle input support TLS?
"""


import pytest
import sys
import re
from typing import List


tests = """abba[mnop]qrst
abcd[bddb]xyyx
aaaa[qwer]tyui
ioxxoj[asdfgh]zxcvbn
testts[qweoifjj]weoinjjoow[weoin]oijloaiw"""


def test_split_braket_text() -> None:
    test_splits = [
        (['abba', 'qrst'], ['mnop']),
        (['abcd', 'xyyx'], ['bddb']),
        (['aaaa', 'tyui'], ['qwer']),
        (['ioxxoj', 'zxcvbn'], ['asdfgh']),
        (['testts', 'weoinjjoow', 'oijloaiw'], ['qweoifjj', 'weoin']),
    ]

    for test, expected in zip(parse_input(tests), test_splits):
        assert split_bracket_text(test) == expected


def test_has_palindrome() -> None:
    pal_tests = [
        [['abba', 'test'], True],
        [['aaaa'], False],
        [['ioxxoj'], True],
        [['qwer'], False],
    ]
    for text, result in pal_tests:
        assert has_palindrome(text) == result


def test_is_valid_tls() -> None:
    test_expected = [True, False, False, True, True]

    for test, expected in zip(parse_input(tests), test_expected):
        assert is_valid_tls(test) == expected


def split_bracket_text(ipv7: str) -> List[str]:
    """Split text into outside and inside bracket text as lists."""
    all_text = ipv7.replace('[', ' ').replace(']', ' ').split(' ')
    return (all_text[::2], all_text[1::2])


def has_palindrome(words: List[str]) -> bool:
    """Identifies if text has a 4 letter palindrome within it."""
    for word in words:
        if len(word) < 4:
            continue
        for c1, c2, c3, c4 in zip(word, word[1:], word[2:], word[3:]):
            if (c1 + c2 == c4 + c3) & (c1 != c2):
                return True
    else:
        return False


def is_valid_tls(ipv7: str) -> bool:
    """Identifies if the IP string is a valid tls."""
    out_brackets, in_brackets = split_bracket_text(ipv7=ipv7)
    return has_palindrome(out_brackets) & ~has_palindrome(in_brackets)


def parse_input(puz_input: str) -> List[List[str]]:
    """Split puzzle input string by newlines into list of lists."""
    return puz_input.strip('\n').split('\n')



# Main ------------------------------------------------------------------------
def main() -> int:
    # Final puzzle input
    with open("../data/puz_input_2016_d7_pt1.txt", 'r') as f:
        puz_input = f.read()

    ct_ips_support_tls = sum(is_valid_tls(ipv7=ipv7)
                             for ipv7 in parse_input(puz_input=puz_input))

    with open("../results/puz_answer_2016_d7.txt", 'w') as out:
        out.write(f"Part 1 answer: {ct_ips_support_tls:,}")

    print(f"Complete. Answer: {ct_ips_support_tls:,}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
