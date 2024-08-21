import argparse
import shutil
import os
from datetime import datetime
from pathlib import Path
from dotenv import dotenv_values 
# This file is meant to record the ABI for a specific contract per deployment so that it is categorized by date and useable for DOOM backwards compatibility
_dir  = dotenv_values(".env")

version = "2.0.0"

def record_abi(args):    
    contract = args.contract

    # Create the contract name variations
    contractSol = contract + ".sol"
    contractAbi = contract + ".json"

    # Create the directory with the timestamp included
    date  = datetime.fromtimestamp(int(args.timestamp)).isoformat()
    filePath = _dir["DEPLOYMENT_OUT_DIR"] + "/" + version + "/abi"
    os.makedirs(filePath, exist_ok=True)

    # Create the contract's abi file
    f = open(filePath + "/" + contractSol, "w")

    # Set the source and destination paths
    sourcePath = (os.getcwd() + "/out/" + contractSol + "/" + contractAbi)
    destinationPath = (filePath + "/" + contractSol)
    
    # copy the abi
    shutil.copy(sourcePath, destinationPath)
    
def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("contract", type=str)
    parser.add_argument("chain_id", type=str)
    parser.add_argument("timestamp", type=str)
    parser.add_argument("--allchains", action=argparse.BooleanOptionalAction, required=False)
    return parser.parse_args()

def main():
    args = parse_args()
    if(args.chain_id != "31337" or args.allchains):
        record_abi(args)


if __name__ == "__main__":
    main()
