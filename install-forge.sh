#!/bin/bash
set -e

WITH_DEPLOY=$1

source ~/.bashrc
foundryup --version nightly-2cb875799419c907cc3709e586ece2559e6b340e
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

if test -f ./.git ; then
	git submodule update --init --recursive   
fi

if [ $WITH_DEPLOY = "--with-deploy" ]; then
	forge script script/DeployAllModules.s.sol --ffi --broadcast
	bash script/ParseProtocolDeploy.sh
	forge script script/clientScripts/ApplicationDeployAll.s.sol --ffi  --broadcast -vvv --non-interactive
	bash script/ParseApplicationDeploy.sh
fi