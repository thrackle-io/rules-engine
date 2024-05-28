#!/bin/bash
# This script will create the protocol and build an example application. 
# The following variables must be set in the .env
# DEPLOYMENT_OWNER(address that will own the protocol contracts)
# DEPLOYMENT_OWNER_KEY
# APP_ADMIN(Main admin role for example application)
# APP_ADMIN_KEY
# CONFIG_APP_ADMIN(upgradeable contract owner)
# CONFIG_APP_ADMIN_KEY
# LOCAL_RULE_ADMIN(Main rule admin role for example application)
#
# Output can be found in the broadcast folder
echo "##############################################################################"
echo Build The Protocol and a simple test application that contains ERC20 and ERC721
echo "##############################################################################"
echo

# Request and export ETH_RPC_URL
echo Please enter RPC URL
read ETH_RPC_URL


sh script/SetupProtocolDeploy.sh
forge script script/DeployAllModulesPt1.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
sh script/ParseProtocolDeploy.sh
forge script script/DeployAllModulesPt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
forge script script/DeployAllModulesPt3.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
forge script script/DeployAllModulesPt4.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
forge script script/clientScripts/Application_Deploy_01_AppManager.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
sh script/ParseApplicationDeploy.sh 1
forge script script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
sh script/ParseApplicationDeploy.sh 2
forge script script/clientScripts/Application_Deploy_02_ApplicationFT1Pt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
forge script script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
forge script script/clientScripts/Application_Deploy_04_ApplicationNFTUpgradeable.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
sh script/ParseApplicationDeploy.sh 3
forge script script/clientScripts/Application_Deploy_04_ApplicationNFTPt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
forge script script/clientScripts/Application_Deploy_04_ApplicationNFTUpgradeablePt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
# Optional: If you would like to run through tests using the upgradeable token
# sh script/SubUpgradeableTokenForRegularToken.sh
forge script script/clientScripts/Application_Deploy_05_Oracle.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
sh script/ParseApplicationDeploy.sh 4
forge script script/clientScripts/Application_Deploy_06_Pricing.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
sh script/ParseApplicationDeploy.sh 5
forge script script/clientScripts/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL