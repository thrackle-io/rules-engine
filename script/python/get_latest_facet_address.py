import argparse
import json
from datetime import date
from eth_abi import encode
from pathlib import Path
from dotenv import dotenv_values 

_dir  = dotenv_values(".env")
dir = Path(_dir["DEPLOYMENT_OUT_DIR"])
file = Path(_dir["DEPLOYMENT_OUT_DIR"] + _dir["DIAMOND_DEPLOYMENT_OUT_FILE"])

def get_latest_deployed_facet(args):
    record = {}
    facet = None
    diamond = None
    with open(file, 'r') as openfile:
        record = json.load(openfile)

    sorted_records = sorted([date.fromisoformat(date_string) for date_string in record[args.chain_id][args.diamond].keys()], reverse=True)
    for deployment in sorted_records:
        if(args.facet in record[args.chain_id][args.diamond][deployment.isoformat()[:10]].keys()):
            facet = record[args.chain_id][args.diamond][deployment.isoformat()[:10]][args.facet]
            break
    for deployment in sorted_records:
        if("diamond" in record[args.chain_id][args.diamond][deployment.isoformat()[:10]].keys()):
            diamond = record[args.chain_id][args.diamond][deployment.isoformat()[:10]]["diamond"]
            break
    return (facet, diamond)

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("diamond", type=str)
    parser.add_argument("facet", type=str)
    parser.add_argument("chain_id", type=str)
    parser.add_argument("timestamp", type=str)
    return parser.parse_args()


def main():
    args = parse_args()
    (facet,diamond) = get_latest_deployed_facet(args)
    if(not facet or not diamond):
        print("Not Found")
        return
    enc = encode(["address[2]"], [[facet, diamond]])
    print("0x" + enc.hex(), end="")

if __name__ == "__main__":
    main()
