import argparse

def calculate_y(args):
    #y = m*x + b
    m = args.m / (10 ** args.decimals)
    if(args.yInAtto): m *= 10 ** 18
    y = (m * args.x) + args.b
    print(int(y))


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("m", type=int)
    parser.add_argument("decimals", type=int)
    parser.add_argument("b", type=int)
    parser.add_argument("x", type=int)
    parser.add_argument("yInAtto", type=int)
    return parser.parse_args()


def main():
    args = parse_args()
    calculate_y(args)


if __name__ == "__main__":
    main()
