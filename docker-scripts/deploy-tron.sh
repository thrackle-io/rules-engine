#!/bin/bash
set -e

## This script should only ever be run on a `compile-tron` or higher layer of the tron
## Dockerfile, which is where this venv will have been created. If this script is run
## in some other context it will fail on this line due to the missing venv. 
source .venv/bin/activate

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
