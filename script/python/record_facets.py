import argparse
import json
from datetime import datetime
from pathlib import Path
from dotenv import dotenv_values 

_dir  = dotenv_values(".env")
version = "2.1.0"
def record_facets(args):
    date  = datetime.fromtimestamp(int(args.timestamp)).isoformat()[:10]
    record = {}
    # Create the directory with the timestamp included
    date2  = datetime.fromtimestamp(int(args.timestamp)).isoformat()
    filePath = _dir["DEPLOYMENT_OUT_DIR"] + args.chain_id + "/" + version + "/" + date2 + "/diamond"
    dir = Path(filePath)
    file = Path(filePath + "/" + _dir["DIAMOND_DEPLOYMENT_OUT_FILE"])

    dir.mkdir(parents=True, exist_ok=True)
    file.touch(exist_ok= True)
    with open(file, 'r') as openfile:
        try:
            record = json.load(openfile)
        except:
            record = {}
    
    if(not record.get(args.chain_id)):
        record[args.chain_id] = {args.diamond_name: {date:{args.contract : args.address}}}
    elif(not record[args.chain_id].get(args.diamond_name)):
        record[args.chain_id][args.diamond_name] = {date:{args.contract : args.address}}
    elif(not record[args.chain_id][args.diamond_name].get(date)):
        record[args.chain_id][args.diamond_name][date] = {args.contract : args.address}
    else:
        record[args.chain_id][args.diamond_name][date][args.contract] = args.address

    json_object = json.dumps(record, indent=4)
    with open(file, 'w+') as outfile:
        outfile.write(json_object)

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("diamond_name", type=str)
    parser.add_argument("contract", type=str)
    parser.add_argument("address", type=str)
    parser.add_argument("chain_id", type=str)
    parser.add_argument("timestamp", type=str)
    parser.add_argument("--allchains", action=argparse.BooleanOptionalAction, required=False)
    return parser.parse_args()


def main():
    args = parse_args()
    if(args.chain_id != "31337" or args.allchains):
        record_facets(args)


if __name__ == "__main__":
    main()