import argparse
from decimal import *
from math import sqrt

def calculate_y(args):
    # x to y ratio
    getcontext().prec = 28
    x = Decimal(args.x)
    y = Decimal(args.y)
    x_change = Decimal(args.x_in)
    
    y_out = (x_change * y)  / (x + x_change)
    print(int(y_out))

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("x", type=int)
    parser.add_argument("y", type=int)
    parser.add_argument("x_in", type=int)
    return parser.parse_args()


def main():
    args = parse_args()
    calculate_y(args)


if __name__ == "__main__":
    main()
