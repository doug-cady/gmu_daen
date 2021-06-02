"""
Initial exporation, analysis, and modeling of fuel_ferc1 dataset from
data.catalyst.coop/pudl website
"""

import argparse
import pandas as pd
import utils_fuel_ferc as utils


def main(args) -> None:
    data = utils.load_data(infile=args.infile)

    (data.pipe(utils.explore_data)
         .pipe(utils.make_fuel_cost_bar_plot)
         .pipe(utils.make_fuel_cost_scat_plot)
    )

    model_data = utils.fit_sk_lm(data=data)
    utils.fit_stats_lm(model_data=model_data)



if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('infile', type=str,
                        nargs='?', default='-',
                        help='Input file name')
    args = parser.parse_args()
    main(args)
