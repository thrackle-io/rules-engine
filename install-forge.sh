#!/bin/bash

source ~/.bashrc
foundryup
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

git submodule update --init --recursive   

make build deployAll deployAllApp