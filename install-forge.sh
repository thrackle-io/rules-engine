#!/bin/bash

source ~/.bashrc
foundryup
pip install -r requirements.txt
make deployAll deployAllApp