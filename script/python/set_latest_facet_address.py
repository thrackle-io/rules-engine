import argparse
import json
from datetime import date
from eth_abi import encode
from pathlib import Path
from dotenv import dotenv_values 

_dir  = dotenv_values(".env")
dir = Path(_dir["DEPLOYMENT_OUT_DIR"])
file = Path(_dir["DEPLOYMENT_OUT_DIR"] + _dir["DIAMOND_DEPLOYMENT_OUT_FILE"])

def set_latest_deployed_facet(args):
    record = {}
    facet = None
    result = 'false'
    with open(file, 'r') as openfile:
        record = json.load(openfile)

    sorted_records = sorted([date.fromisoformat(date_string) for date_string in record[args.chain_id][args.diamond].keys()], reverse=True)
    for deployment in sorted_records:
        if(args.facet in record[args.chain_id][args.diamond][deployment.isoformat()[:10]].keys()):
            record[args.chain_id][args.diamond][deployment.isoformat()[:10]][args.facet] = args.facet_address 
            with open(file, 'w') as f:
                json.dump(record, f, indent=2)
            result = 'true'
            break

    return result

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("diamond", type=str)
    parser.add_argument("facet", type=str)
    parser.add_argument("facet_address", type=str)
    parser.add_argument("chain_id", type=str)
    return parser.parse_args()


def main():
    args = parse_args()
    result = set_latest_deployed_facet(args)
    if(not result):
        print("Not Found")
        return
    

if __name__ == "__main__":
    main()
