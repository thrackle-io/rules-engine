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
echo Please enter the chain id
read CHAIN_ID
echo "Rule Processor Deployment Required? (y or n)"
read DEPLOYMENT
echo "Is this deployment local? (y or n)"
read LOCAL
echo Please enter the gas price
read GAS_NUMBER

if [ "$LOCAL" = "y" ]; then
  sh script/SetupProtocolDeploy.sh --chainid $CHAIN_ID
fi
DEPLOYMENT=$(echo "$DEPLOYMENT" | tr '[:upper:]' '[:lower:]')
if [ "$DEPLOYMENT" = "y" ]; then 
  forge script script/DeployAllModulesPt1.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
  sh script/ParseProtocolDeploy.sh --chainid $CHAIN_ID
  forge script script/DeployAllModulesPt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
  forge script script/DeployAllModulesPt3.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
  forge script script/DeployAllModulesPt4.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
fi
forge script script/clientScripts/Application_Deploy_01_AppManager.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
sh script/ParseApplicationDeploy.sh 1 --chainid $CHAIN_ID
echo "Do you already have an ERC20 deployed (y or n)?"
read DEPLOYED
DEPLOYED=$(echo "$DEPLOYED" | tr '[:upper:]' '[:lower:]')  
while [ "y" != "$DEPLOYED" ] && [ "n" != "$DEPLOYED" ] ; do
  echo
  echo "Not a valid answer (y or n)"
  echo "Do you already have an ERC20 deployed (y or n)?"
  read DEPLOYED
  DEPLOYED=$(echo "$DEPLOYED" | tr '[:upper:]' '[:lower:]')  
done
if [ "$DEPLOYED" = "y" ]; then
    echo "Is the deployed ERC20 already protocol enabled (connected to a handler) (y or n)?"
    read CONNECTED_ALREADY
    CONNECTED_ALREADY=$(echo "$CONNECTED_ALREADY" | tr '[:upper:]' '[:lower:]')  
    while [ "y" != "$CONNECTED_ALREADY" ] && [ "n" != "$CONNECTED_ALREADY" ] ; do
    echo
    echo "Not a valid answer (y or n)"
    echo "Is the deployed ERC20 already protocol enabled (connected to a handler) (y or n)?"
    read DEPLOYED
    CONNECTED_ALREADY=$(echo "$CONNECTED_ALREADY" | tr '[:upper:]' '[:lower:]')  
    done
    if [ "$CONNECTED_ALREADY" = "n" ]; then
      forge script script/clientScripts/DeployERC20Handler.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
      forge script script/clientScripts/DeployERC20HandlerPt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    fi
else 
    forge script script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    sh script/ParseApplicationDeploy.sh 2 --chainid $CHAIN_ID
    forge script script/clientScripts/Application_Deploy_02_ApplicationFT1Pt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    forge script script/clientScripts/Application_Deploy_03_ApplicationFT2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    sh script/ParseApplicationDeploy.sh 6 --chainid $CHAIN_ID
    forge script script/clientScripts/Application_Deploy_03_ApplicationFT2Pt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    forge script script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    forge script script/clientScripts/Application_Deploy_04_ApplicationNFTUpgradeable.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    sh script/ParseApplicationDeploy.sh 3 --chainid $CHAIN_ID
    forge script script/clientScripts/Application_Deploy_04_ApplicationNFTPt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    forge script script/clientScripts/Application_Deploy_04_ApplicationNFTUpgradeablePt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    # Optional: If you would like to run through tests using the upgradeable token
    # sh script/SubUpgradeableTokenForRegularToken.sh
    forge script script/clientScripts/Application_Deploy_05_Oracle.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    sh script/ParseApplicationDeploy.sh 4 --chainid $CHAIN_ID
    forge script script/clientScripts/Application_Deploy_06_Pricing.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    sh script/ParseApplicationDeploy.sh 5 --chainid $CHAIN_ID
    forge script script/clientScripts/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
  fi