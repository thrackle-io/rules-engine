import argparse
from decimal import *
from math import sqrt

def calculate_x(args):
    # x to y ratio
    getcontext().prec = 28
    x = Decimal(args.x)
    y = Decimal(args.y)
    y_change = Decimal(args.y_in)
    
    x = y_change * x  / y
    print(int(x))

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("x", type=int)
    parser.add_argument("y", type=int)
    parser.add_argument("y_in", type=int)
    return parser.parse_args()


def main():
    args = parse_args()
    calculate_x(args)


if __name__ == "__main__":
    main()
