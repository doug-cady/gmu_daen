"""
Design and implement a Python program that is based on the following requirements:
a) program will find all numbers -- within a specified range --
    which are divisible by 7 but are not a multiple of 5; and
b) demonstrate the program works by running the program for the range:
    numbers between 2000 and 3200.
"""

from typing import List


def div_7_not_5_mult(rng_lo: int, rng_hi: int) -> List[int]:
    """ Return list of ints between inclusive range that are divisible
        by 7, but are not multiples of 5
    """
    out = []

    for num in range(rng_lo, rng_hi+1):
        if (num % 7 == 0) and (num % 5 != 0):
            out.append(num)

    return out


if __name__ == '__main__':
    result = div_7_not_5_mult(rng_lo=2000, rng_hi=3200)

    print(result)

