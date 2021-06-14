"""
Advent of Code 2016
Day 5: How About a Nice Game of Chess?

[Part 2]
Instead of simply filling in the password from left to right, the hash now also
indicates the position within the password to fill. You still look for hashes
that begin with five zeroes; however, now, the sixth character represents the
position (0-7), and the seventh character is the character to put in that position.

A hash result of 000001f means that f is the second character in the password.
Use only the first result for each position, and ignore invalid positions.

For example, if the Door ID is abc:

    The first interesting hash is from abc3231929, which produces 0000015...;
    so, 5 goes in position 1: _5______.
    In the previous method, 5017308 produced an interesting hash; however, it
    is ignored, because it specifies an invalid position (8).
    The second interesting hash is at index 5357525, which produces 000004e...;
    so, e goes in position 4: _5__e___.

You almost choke on your popcorn as the final character falls into place,
producing the password 05ace8e3.
"""


import pytest
import sys
import hashlib
from itertools import count


def test_assemble_password() -> None:
    assert assemble_password(puz_input="abc") == "05ace8e3"


def assemble_password(puz_input: str) -> str:
    """Follow password instructions and assemble one character at a time."""
    password = [' '] * 8
    idx_set = set()

    for num in count(0):
        if len(idx_set) == 8:
            break

        plaintext = puz_input + str(num)
        hashtext = hashlib.md5(plaintext.encode()).hexdigest()

        if hashtext[:5] == "00000":
            if '0' <= hashtext[5] < '8':
                idx = int(hashtext[5])

                if idx not in idx_set:
                    idx_set.add(idx)
                    password[idx] = hashtext[6]
                    print(password)

    return ''.join(password)


def main() -> int:
    # Final puzzle input
    puz_input = "reyedfim"
    final_pass = assemble_password(puz_input=puz_input)

    with open("../results/puz_answer_2016_d5.txt", 'a') as out:
        out.write(f"\nPart 2 answer: {final_pass}")

    print(f"Complete. Answer: {final_pass}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
