"""
Solving Advent of Code 2016 day 4 problem (part 2)
Security Through Obscurity:

The room names are encrypted by a state-of-the-art shift cipher, which is
nearly unbreakable without the right software. However, the information
kiosk designers at Easter Bunny HQ were not expecting to deal with a
master cryptographer like yourself.

To decrypt a room name, rotate each letter forward through the alphabet a
number of times equal to the room's sector ID. A becomes B, B becomes C, Z
becomes A, and so on. Dashes become spaces.

For example, the real name for 'qzmt-zixmtkozy-ivhz-343' is 'very encrypted name'.
"""

import pytest
import re
import sys
import string
from typing import List, NamedTuple


class RoomDetails(NamedTuple):
    encrypted_name: str
    sector_id: str
    checksum: str


class RoomNameSector(NamedTuple):
    decrypted_name: str
    sector_id: int


TESTS = {
    "input": "qzmt-zixmtkozy-ivhz-343[imtqz]",
    "answer": RoomNameSector("very encrypted name", 343)
}

LETTERS = string.ascii_lowercase


def test_decrypt_room_names() -> None:
    test_room = parse_rooms(rooms=[TESTS['input']])
    print(test_room)
    obs_result = decrypt_room_names(room=test_room[0])
    assert obs_result == TESTS['answer']


def decrypt_room_names(room: RoomDetails) -> RoomNameSector:
    """Apply shift cypher to decrypt room names as returned list."""
    decrypted_name = []
    sector_id = int(room.sector_id)

    for letter in room.encrypted_name.replace('-', ' '):
        if letter == ' ':
            decrypted_name += letter
            continue
        idx = LETTERS.index(letter)
        adj_idx = (idx + sector_id) % len(LETTERS)
        decrypted_name += LETTERS[adj_idx]

    return RoomNameSector(''.join(decrypted_name).strip(' '), sector_id)


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
    room_names_ids = [decrypt_room_names(room=room) for room in rooms_parsed]

    north_pole_room = [room_name_id for room_name_id in room_names_ids
                       if 'north' in room_name_id.decrypted_name]

    print(north_pole_room) #

    with open("../results/puz_answer_2016_d4.txt", 'a') as o:
        o.write(f"\nPart 2 answer: {north_pole_room[0].sector_id:,}")

    # print(f"Complete. Answer: {sum_real_room_sectorIDs}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
