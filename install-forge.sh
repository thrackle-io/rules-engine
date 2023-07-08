#!/bin/bash

source ~/.bashrc
foundryup
pip install -r requirements.txt
git submodule update --init --recursive
make deployAll deployAllApp