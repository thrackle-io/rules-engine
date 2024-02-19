#!/bin/bash
set -e

WITH_DEPLOY=$1

source ~/.bashrc
foundryup --version nightly-fd87629fbc4ae2e0fa00ccf42b4a9ebe1b521d55
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

if test -f ./.git ; then
	git submodule update --init --recursive   
fi

if [ $WITH_DEPLOY = "--with-deploy" ]; then
	forge script script/DeployAllModulesPt1.s.sol --ffi --broadcast
	bash script/ParseProtocolDeploy.sh
	forge script script/DeployAllModulesPt2.s.sol --ffi --broadcast
	forge script script/DeployAllModulesPt3.s.sol --ffi --broadcast
	forge script script/clientScripts/ApplicationDeployAll.s.sol --ffi  --broadcast -vvv --non-interactive
	bash script/ParseApplicationDeploy.sh
fi