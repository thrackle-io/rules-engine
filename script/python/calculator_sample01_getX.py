import argparse
from decimal import *
from math import sqrt

def calculate_x(args):
    # Neel's Razor(Sample01)
    getcontext().prec = 28
    g_tracker = Decimal(args.tracker)
    y_change = Decimal(args.y_in)
    # NOTE: This equation should be refined. Currently, it is set to match the solidity but it should be changed to a research approved version
    deltaYSquareRoot = Decimal(sqrt(g_tracker + y_change))
    trackerSquareRoot = Decimal(sqrt(g_tracker))
    x_out = Decimal((10 ** 9) * (deltaYSquareRoot - trackerSquareRoot))
    print(int(x_out))

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("tracker", type=int)
    parser.add_argument("y_in", type=int)
    return parser.parse_args()


def main():
    args = parse_args()
    calculate_x(args)


if __name__ == "__main__":
    main()
