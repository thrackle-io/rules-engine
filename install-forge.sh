#!/bin/bash

source ~/.bashrc
foundryup
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

## This line fails because the git repo isn't actually on the container, just a copy of all the code... 
## Do we need this??
#git submodule update --init --recursive   

make deployAll deployAllApp