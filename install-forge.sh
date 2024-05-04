#!/bin/bash
set -e

SCRIPT_MODE=$1

source ~/.bashrc
# Pin foundry to a known-good commit hash. Awk ignores comments in `foundry.lock`
#foundryup --commit $(awk '$1~/^[^#]/' foundry.lock)
foundryup --version nightly-d495216638c0adaa3df76190a6835537c579304d
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

forge build
