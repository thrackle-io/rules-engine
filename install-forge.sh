#!/bin/bash
set -e

WITH_DEPLOY=$1

source ~/.bashrc
foundryup
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

git submodule update --init --recursive   

if [ $WITH_DEPLOY = "--with-deploy" ]; then
	make build deployAll deployAllApp
fi