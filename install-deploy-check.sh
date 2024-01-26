#!/bin/bash

source ~/.bashrc
foundryup
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

git submodule update --init --recursive   

forge script script/DeployAllModules.s.sol --ffi --broadcast
sh script/ParseProtocolDeploy.sh
forge script script/clientScripts/ApplicationDeployAll.s.sol --ffi  --broadcast -vvv --non-interactive
sh script/ParseApplicationDeploy.sh
forge test --ffi -vv --match-contract ApplicationDeploymentTest