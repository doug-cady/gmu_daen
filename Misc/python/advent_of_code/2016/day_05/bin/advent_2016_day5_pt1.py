"""
Advent of Code 2016
Day 5: How About a Nice Game of Chess?

[Part 1]
The eight-character password for the door is generated one character at a time
by finding the MD5 hash of some Door ID (your puzzle input) and an increasing
integer index (starting with 0).

A hash indicates the next character in the password if its hexadecimal
representation starts with five zeroes. If it does, the sixth character in
the hash is the next character of the password.

For example, if the Door ID is abc:

The first index which produces a hash that starts with five zeroes is 3231929,
which we find by hashing abc3231929; the sixth character of the hash, and thus
the first character of the password, is 1.
"""


import pytest
import sys
import hashlib
from itertools import count


def test_assemble_password() -> None:
    assert assemble_password(puz_input="abc") == "18f47a30"


def assemble_password(puz_input: str) -> str:
    """Follow password instructions and assemble one character at a time."""
    password = []

    for num in count(0):
        if len(password) == 8:
            break

        plaintext = puz_input + str(num)
        hashtext = hashlib.md5(plaintext.encode()).hexdigest()
        if hashtext[:5] == "00000":
            print(hashtext[5])
            password += [hashtext[5]]

    return ''.join(password)


# Main ------------------------------------------------------------------------
def main() -> int:
    # Final puzzle input
    puz_input = "reyedfim"
    final_pass = assemble_password(puz_input=puz_input)

    with open("../results/puz_answer_2016_d5.txt", 'w') as out:
        out.write(f"Part 1 answer: {final_pass}")

    print(f"Complete. Answer: {final_pass}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
