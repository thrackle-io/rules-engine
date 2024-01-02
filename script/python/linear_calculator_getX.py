import argparse
from decimal import *
from math import sqrt

def calculate_x(args):
    # x_0 = reserve of token x
    # x_change = amount of x being swapped in
    # m = slope
    # b = y intercept
    # d = token decimals(usually 10^18)
    getcontext().prec = 18
    m = Decimal(args.m)
    m_den = Decimal(args.m_denom)
    y_0 = Decimal(args.y_reserve)
    y_change = Decimal(args.y_in)
    b = Decimal(args.b)
    b_den = Decimal(args.b_denom)
    d = Decimal(args.token_decimals)   

    x = (Decimal(2) * (Decimal(10) ** Decimal(9)) * y_change * b_den * Decimal(sqrt(m_den))) / (Decimal(sqrt((Decimal(10) ** Decimal(18)) * (b ** Decimal(2)) * m_den + Decimal(2) * y_0 * m * (b_den ** Decimal(2)))) + Decimal(sqrt((Decimal(10) ** Decimal(18)) * (b ** Decimal(2)) * m_den + (2 * (y_0 + y_change) * m * (b_den ** Decimal(2)))))) 
    
    print(int(x))

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("m", type=int)
    parser.add_argument("m_denom", type=int)
    parser.add_argument("token_decimals", type=int)
    parser.add_argument("b", type=int)
    parser.add_argument("b_denom", type=int)
    parser.add_argument("y_reserve", type=int)
    parser.add_argument("y_in", type=int)
    return parser.parse_args()


def main():
    args = parse_args()
    calculate_x(args)


if __name__ == "__main__":
    main()
