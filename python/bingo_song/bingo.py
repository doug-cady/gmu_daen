"""
As I was singing bedtime songs to my daughter tonight,
I thought I could write a simple program to write out the lyrics
to B-I-N-G-O and add it to my git profile.
"""

import random

animal_noise_map = {
    'cow':   'moo',
    'duck':  'quack',
    'frog':  'ribbit',
    'cat':   'meow',
    'horse': 'neigh',
    'pig':   'oink',
    'dinosaur': 'rooaarrr'
}


def sing() -> None:
    """ Prints lyrics to song """
    random_animal = random.choice(list(animal_noise_map.keys()))
    random_noise = animal_noise_map[random_animal]

    print("~ Lyrics to BINGO with a", random_animal, "~\n")

    for verse in range(6):
        chorus = ', '.join([random_noise]*verse + bingo[verse:])

        song = [line_1 + random_animal] + [line_2_6] + [chorus]*3 + [line_2_6]
        print('\n'.join(song), end='\n\n')


if __name__ == '__main__':
    bingo = ['B', 'I', 'N', 'G', 'O']

    line_1 = "There was a farmer who had a "
    line_2_6 = "and bingo was his name-o"

    sing()

