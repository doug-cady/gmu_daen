"""Count occurence of sentence ending punctations in a given file."""

import argparse


def count_punctuation(reader):
    """Count the occurence of each type of punctuation."""
    text = reader.read()
    punct_cts = [f"Number of {punct} is {text.count(punct)}"
                 for punct in [".", "?", "!"]]
    print("\n".join(punct_cts))


def main(args):
    """Run the command line program."""
    count_punctuation(args.infile)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('infile', type=argparse.FileType('r'),
                        nargs='?', default='-', help='Input file name')
    # parser.add_argument('suffix', type=str,
    #                     help='File suffix (e.g. py, sh')
    args = parser.parse_args()
    main(args)
