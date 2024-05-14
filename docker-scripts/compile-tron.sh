#!/bin/bash
set -e

## Addint a comment to invalidate a cache layer for testing

python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

forge build