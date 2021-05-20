"""Create a plot of word counts with given ."""

import argparse
import pandas as pd
from typing import List


def parse_xlims(str_xlim: str) -> List[int]:
    """Parse xlim string optional argument into a list of ints."""
    list_xlim = str_xlim. \
        strip("["). \
        strip("]"). \
        split(",")

    return [int(xlim.strip()) for xlim in list_xlim]

# assert parse_xlims("[10, 40]") == [10, 40]


def make_word_freq_plot(args) -> None:
    """Count the occurence of each type of punctuation."""
    df = pd.read_csv(args.infile, header=None,
                     names=('word', 'word_frequency'))
    df['rank'] = df['word_frequency'].rank(ascending=False,
                                       method='max')
    df['inverse_rank'] = 1 / df['rank']
    scatplot = df.plot.scatter(x='word_frequency',
                               y='inverse_rank',
                               figsize=[12, 6],
                               grid=True)
    if args.xlim:
        xlims = parse_xlims(str_xlim=args.xlim)
        scatplot.set_xlim(xlims)
    fig = scatplot.get_figure()
    fig.savefig(f'{args.outfile}')


def main(args):
    """Run the command line program."""
    make_word_freq_plot(args=args)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('infile', type=argparse.FileType('r'),
                        nargs='?', default='-', help='Input file name')
    parser.add_argument('--outfile', type=str, default='results/plotcounts.png',
                        help='Output file name')
    parser.add_argument('--xlim', type=str, nargs='?',
                        help='Plot x limits')
    args = parser.parse_args()
    main(args)
