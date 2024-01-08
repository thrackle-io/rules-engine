import argparse
from decimal import *
from math import sqrt

def calculate_y(args):
    # Neel's Razor(Sample01)
    getcontext().prec = 28
    f_tracker = Decimal(args.tracker)
    x_change = Decimal(args.x_in)
    # NOTE: This equation should be refined. Currently, it is set to match the solidity but it should be changed to a research approved version
    tenMinusTrackerSquare = Decimal(((10 ** 19) - f_tracker) ** 2)
    tenMinusDeltaSquare = Decimal(((10 ** 19) - (f_tracker + x_change))**2)
    y_out = Decimal((tenMinusTrackerSquare - tenMinusDeltaSquare) / Decimal((2 * (10 ** 18))))
    print(int(y_out))

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("tracker", type=int)
    parser.add_argument("x_in", type=int)
    return parser.parse_args()


def main():
    args = parse_args()
    calculate_y(args)


if __name__ == "__main__":
    main()
