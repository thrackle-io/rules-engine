#!/bin/bash
set -e

SCRIPT_MODE=$1

source ~/.bashrc
foundryup --commit $(awk '$1~/^[^#]/' foundry.lock)
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

if [ $SCRIPT_MODE = "--with-build" ]; then
	forge build
fi

if [ $SCRIPT_MODE = "--with-deploy" ]; then
	source script/SetupProtocolDeploy.sh
	forge script script/DeployAllModulesPt1.s.sol --ffi --broadcast
	source script/ParseProtocolDeploy.sh
	forge script script/DeployAllModulesPt2.s.sol --ffi --broadcast
	forge script script/DeployAllModulesPt3.s.sol --ffi --broadcast
  	forge script script/DeployAllModulesPt4.s.sol --ffi --broadcast
	forge script script/clientScripts/Application_Deploy_01_AppManager.s.sol --ffi --broadcast
	source script/ParseApplicationDeploy.sh 1
	forge script script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol --ffi --broadcast 
	source script/ParseApplicationDeploy.sh 2
	forge script script/clientScripts/Application_Deploy_02_ApplicationFT1Pt2.s.sol --ffi --broadcast
	forge script script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol --ffi --broadcast
	source script/ParseApplicationDeploy.sh 3
	forge script script/clientScripts/Application_Deploy_04_ApplicationNFTPt2.s.sol --ffi --broadcast
	forge script script/clientScripts/Application_Deploy_05_Oracle.s.sol --ffi --broadcast 
	source script/ParseApplicationDeploy.sh 4
	forge script script/clientScripts/Application_Deploy_06_Pricing.s.sol --ffi --broadcast
	source script/ParseApplicationDeploy.sh 5
	forge script script/clientScripts/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --broadcast
fi
