"""
Advent of Code 2016
Day 7: Internet Protocol Version 7

[Part 2]
You would also like to know which IPs support SSL (super-secret listening).

An IP supports SSL if it has an Area-Broadcast Accessor, or ABA, anywhere in
the supernet sequences (outside any square bracketed sections), and a
corresponding Byte Allocation Block, or BAB, anywhere in the hypernet sequences.
An ABA is any three-character sequence which consists of the same character
twice with a different character between them, such as xyx or aba. A
corresponding BAB is the same characters but in reversed positions: yxy and
bab, respectively.

For example:

 -  aba[bab]xyz supports SSL (aba outside square brackets with corresponding
    bab within square brackets).
 -  xyx[xyx]xyx does not support SSL (xyx, but no corresponding yxy).
 -  aaa[kek]eke supports SSL (eke in supernet with corresponding kek in
    hypernet; the aaa sequence is not related, because the interior character
    must be different).
 -  zazbz[bzb]cdb supports SSL (zaz has no corresponding aza, but zbz has a corresponding bzb, even though zaz and zbz overlap).

How many IPs in your puzzle input support SSL?
"""


import pytest
import sys
import re
from typing import List, Dict


tests = """aba[bab]xyz
xyx[xyx]xyx
aaa[kek]eke
zazbz[bzb]cdb"""


def test_find_palindromes() -> None:
    pal_tests = [
        [['aba', 'xyz'], set(['aba'])],
        [['aaaa'], set()],
        [['ioxoj'], set(['oxo'])],
        [['qwer'], set()],
    ]
    for text, result in pal_tests:
        assert find_palindromes(text) == result


def test_is_valid_ssl() -> None:
    test_expected = [True, False, True, True]

    for test, expected in zip(parse_input(tests), test_expected):
        assert is_valid_ssl(test) == expected


def split_bracket_text(ipv7: str) -> Dict[str, List[str]]:
    """Split text into outside and inside bracket text as lists."""
    all_text = ipv7.replace('[', ' ').replace(']', ' ').split(' ')
    return {'out_brackets': all_text[0::2],
            'in_brackets':  all_text[1::2]}


def find_palindromes(words: List[str]) -> set:
    """Identifies all 3 letter palindromes within a list of words."""
    three_char_palindromes = set()

    for word in words:
        if len(word) < 3:
            continue
        for c1, c2, c3 in zip(word, word[1:], word[2:]):
            if (c1 == c3) & (c1 != c2):
                three_char_palindromes.add(''.join([c1, c2, c3]))

    return three_char_palindromes


def reverse_palindromes(pals: set) -> set:
    """Reverse 3 character palindromes to enable set matching between in and
    out bracket sets. Ex: 'aba' -> 'bab'

    """
    return set(''.join([pal[1:], pal[1]]) for pal in list(pals))


def is_valid_ssl(ipv7: str) -> bool:
    """Identifies if the IP string is a valid ssl with matching 3 character
    palindromes outside and inside brackets (reversed palindrome).
    Ex: aba[bab]xyz is valid because aba == rev(bab)

    """
    palindromes = {key: find_palindromes(words=text_list)
                   for key, text_list in split_bracket_text(ipv7=ipv7).items()}
    # in_out_bracket_text = split_bracket_text(ipv7=ipv7)
    # pals_out_brackets = find_palindromes(words=out_brackets)
    # pals_in_brackets = find_palindromes(words=in_brackets)
    palindromes['rev_in_brackets'] = reverse_palindromes(
        pals=palindromes['in_brackets'])
    # rev_pals_in_brackets = reverse_palindromes(pals=pals_in_brackets)
    return len(palindromes['out_brackets'] & palindromes['rev_in_brackets']) > 0


def parse_input(puz_input: str) -> List[List[str]]:
    """Split puzzle input string by newlines into list of lists."""
    return puz_input.strip('\n').split('\n')



def main() -> int:
    # Final puzzle input
    with open("../data/puz_input_2016_d7_pt1.txt", 'r') as f:
        puz_input = f.read()

    ct_ips_support_ssl = sum(is_valid_ssl(ipv7=ipv7)
                             for ipv7 in parse_input(puz_input=puz_input))

    with open("../results/puz_answer_2016_d7.txt", 'a') as out:
        out.write(f"\nPart 2 answer: {ct_ips_support_ssl:,}")

    print(f"Complete. Answer: {ct_ips_support_ssl:,}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
