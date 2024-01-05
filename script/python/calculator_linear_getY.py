import argparse
from decimal import *

def calculate_y(args):
    # y = mx + b
    
    # x_0 = reserve of token x
    # x_change = amount of x being swapped in
    # m = slope
    # b = y intercept
    # d = token decimals(usually 10^18)
    getcontext().prec = 18
    m = Decimal(args.m)
    m_den = Decimal(args.m_decimals)
    x_0 = Decimal(args.x_reserve)
    x_change = Decimal(args.x_in)
    b = Decimal(args.b)
    b_den = Decimal(args.b_decimals)
    d = Decimal(args.token_decimals)   
    y = ((b * x_change) / b_den) + (m * ((Decimal(2) * x_0 * x_change ) - (x_change ** 2)) / (Decimal(2) * m_den * d))
    print(int(y))

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("m", type=int)
    parser.add_argument("m_decimals", type=int)
    parser.add_argument("token_decimals", type=int)
    parser.add_argument("b", type=int)
    parser.add_argument("b_decimals", type=int)
    parser.add_argument("x_reserve", type=int)
    parser.add_argument("x_in", type=int)
    return parser.parse_args()


def main():
    args = parse_args()
    calculate_y(args)


if __name__ == "__main__":
    main()
