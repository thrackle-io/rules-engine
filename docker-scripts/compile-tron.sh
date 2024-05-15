#!/bin/bash
set -e

source ~/.bashrc

# Testing GHA docker layer caching

python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

forge build