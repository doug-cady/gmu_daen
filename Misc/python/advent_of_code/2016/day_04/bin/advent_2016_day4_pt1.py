"""
Solving Advent of Code 2016 day 4 problem
Security Through Obscurity:

Each room consists of an encrypted name (lowercase letters separated
by dashes) followed by a dash, a sector ID, and a checksum in square brackets.

A room is real (not a decoy) if the checksum is the five most common letters
in the encrypted name, in order, with ties broken by alphabetization.

For example:
aaaaa-bbb-z-y-x-123[abxyz] is a real room because the most common letters
are a (5), b (3), and then a tie between x, y, and z, which are listed
alphabetically.
"""

import pytest
import re
import sys
from collections import Counter, OrderedDict
from typing import List, NamedTuple


class RoomDetails(NamedTuple):
    encrypted_name: str
    sector_id: str
    checksum: str


tests = [
    ["aaaaa-bbb-z-y-x-123[abxyz]",
     "a-b-c-d-e-f-g-h-987[abcde]",
     "not-a-real-room-404[oarel]",
     "totally-real-room-200[decoy]"],
    [RoomDetails("aaaaa-bbb-z-y-x-", "123", "abxyz"),
     RoomDetails("a-b-c-d-e-f-g-h-", "987", "abcde"),
     RoomDetails("not-a-real-room-", "404", "oarel"),
     RoomDetails("totally-real-room-", "200", "decoy")],
    [123,
     987,
     404,
     0]
]


def test_parse_rooms() -> None:
    assert parse_rooms(tests[0]) == tests[1]


def test_match_checksum() -> None:
    for room_dets, exp_result in zip(tests[1], tests[2]):
        assert match_checksum(room_dets) == exp_result


def test_integration() -> None:
    rooms_parsed = parse_rooms(rooms=tests[0])
    sum_real_room_sectorIDs = sum(match_checksum(room) for room in rooms_parsed)
    assert sum_real_room_sectorIDs == 1514


def match_checksum(room: RoomDetails) -> int:
    """Validates if room is 'real' based on criteria in __doc__."""
    letter_cts = Counter(room.encrypted_name.replace('-', ''))
    sorted_cts = OrderedDict(sorted(letter_cts.items(),
                                    key=lambda item: (-item[1], item[0])))

    if ''.join(sorted_cts.keys())[:5] == room.checksum:
        return int(room.sector_id)
    else:
        return 0


def parse_rooms(rooms: List[str]) -> List[RoomDetails]:
    """Parse room into 3 parts - encrypted name, sectorID, and checksum."""
    room_pattern = r"([a-z\-]+)(\d+)\[([a-z]+)\]"
    room_regex = re.compile(room_pattern)
    return [RoomDetails(*(room_regex.search(room)).groups()) for room in rooms]


# Main ------------------------------------------------------------------------
def main() -> int:
    # Final puzzle input
    with open("../data/puz_input_2016_d4_pt1.txt", 'r') as f:
        puz_input_text = f.read().strip('\n').split('\n')

    rooms_parsed = parse_rooms(rooms=puz_input_text)
    sum_real_room_sectorIDs = sum(match_checksum(room) for room in rooms_parsed)

    with open("../results/puz_answer_2016_d4.txt", 'w') as o:
        o.write(f"Part 1 answer: {sum_real_room_sectorIDs:,}")

    print(f"Complete. Answer: {sum_real_room_sectorIDs}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
