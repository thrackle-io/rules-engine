#!/bin/bash
set -e

source ~/.bashrc

# Just testing GHA layer caching, need a commit to push...

python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

forge build