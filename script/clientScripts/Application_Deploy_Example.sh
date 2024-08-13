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
echo "Does the Protocol (Rule Processor Diamond) need to be deployed to target chain? (y or n)"
read DEPLOYMENT
echo "Is this deployment local? (y or n)"
read LOCAL
echo "Is a full application deployment required? (y or n)"
read FULL_APPLICATION
echo Please enter the gas price
read GAS_NUMBER

if [ "$LOCAL" = "y" ]; then
  sh script/SetupProtocolDeploy.sh --chainid $CHAIN_ID
fi
DEPLOYMENT=$(echo "$DEPLOYMENT" | tr '[:upper:]' '[:lower:]')
if [ "$DEPLOYMENT" = "y" ]; then 
  export GAS_NUMBER=$GAS_NUMBER
  export ETH_RPC_URL=$ETH_RPC_URL
  export CHAIN_ID=$CHAIN_ID
  sh script/deploy/DeployProtocol.sh 
fi
# if FULL_APPLICATION = y run app manager else ask if app manager is needed 
while [ "y" != "$FULL_APPLICATION" ] && [ "n" != "$FULL_APPLICATION" ] ; do
  echo
  echo "Not a valid answer (y or n)"
  echo "Is a full application deployment required? (y or n)"
  read FULL_APPLICATION
  FULL_APPLICATION=$(echo "$FULL_APPLICATION" | tr '[:upper:]' '[:lower:]')  
done
if [ "$FULL_APPLICATION" = "n" ]; then 
  echo "Do you want to deploy an Application Manager? (y or n)?"
  read APP_MANAGER_DEPLOYED
  APP_MANAGER_DEPLOYED=$(echo "$APP_MANAGER_DEPLOYED" | tr '[:upper:]' '[:lower:]')  
  while [ "y" != "$APP_MANAGER_DEPLOYED" ] && [ "n" != "$APP_MANAGER_DEPLOYED" ] ; do
    echo
    echo "Not a valid answer (y or n)"
    echo "Do you want to deploy an Application Manager? (y or n)?"
    read APP_MANAGER_DEPLOYED
    APP_MANAGER_DEPLOYED=$(echo "$APP_MANAGER_DEPLOYED" | tr '[:upper:]' '[:lower:]')  
  done
  if [ "$APP_MANAGER_DEPLOYED" = "n" ]; then
    forge script script/clientScripts/Application_Deploy_01_AppManager.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    sh script/ParseApplicationDeploy.sh 1 --chainid $CHAIN_ID
  fi

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
    echo "Do you want to deploy an ERC20 (y or n)?"
    read ERC20_DEPLOYMENT
    ERC20_DEPLOYMENT=$(echo "$ERC20_DEPLOYMENT" | tr '[:upper:]' '[:lower:]')  
    while [ "y" != "$ERC20_DEPLOYMENT" ] && [ "n" != "$ERC20_DEPLOYMENT" ] ; do
    echo
    echo "Not a valid answer (y or n)"
    echo "Do you want to deploy an ERC20 (y or n)?"
    read ERC20_DEPLOYMENT
    ERC20_DEPLOYMENT=$(echo "$ERC20_DEPLOYMENT" | tr '[:upper:]' '[:lower:]')  
    done
    if [ "$ERC20_DEPLOYMENT" = "y" ]; then
      forge script script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
      sh script/ParseApplicationDeploy.sh 2 --chainid $CHAIN_ID
      forge script script/clientScripts/Application_Deploy_02_ApplicationFT1Pt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    fi
    echo "Do you want to deploy another ERC20 (y or n)?"
    read ERC20_DEPLOYMENT_2
    ERC20_DEPLOYMENT_2=$(echo "$ERC20_DEPLOYMENT_2" | tr '[:upper:]' '[:lower:]')  
    while [ "y" != "$ERC20_DEPLOYMENT_2" ] && [ "n" != "$ERC20_DEPLOYMENT_2" ] ; do
    echo
    echo "Not a valid answer (y or n)"
    echo "Do you want to deploy another ERC20 (y or n)?"
    read ERC20_DEPLOYMENT_2
    ERC20_DEPLOYMENT_2=$(echo "$ERC20_DEPLOYMENT_2" | tr '[:upper:]' '[:lower:]')  
    done
    if [ "$ERC20_DEPLOYMENT_2" = "y" ]; then
        forge script script/clientScripts/Application_Deploy_03_ApplicationFT2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
        sh script/ParseApplicationDeploy.sh 6 --chainid $CHAIN_ID
        forge script script/clientScripts/Application_Deploy_03_ApplicationFT2Pt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    fi
  fi
  
  echo "Do you already have an ERC721 deployed (y or n)?"
  read NFT_DEPLOYED
  NFT_DEPLOYED=$(echo "$NFT_DEPLOYED" | tr '[:upper:]' '[:lower:]')  
  while [ "y" != "$NFT_DEPLOYED" ] && [ "n" != "$NFT_DEPLOYED" ] ; do
    echo
    echo "Not a valid answer (y or n)"
    echo "Do you already have an ERC721 deployed (y or n)?"
    read NFT_DEPLOYED
    NFT_DEPLOYED=$(echo "$NFT_DEPLOYED" | tr '[:upper:]' '[:lower:]')  
  done
  if [ "$NFT_DEPLOYED" = "y" ]; then
    echo "Is the deployed ERC721 already protocol enabled (connected to a handler) (y or n)?"
    read NFT_CONNECTED_ALREADY
    NFT_CONNECTED_ALREADY=$(echo "$NFT_CONNECTED_ALREADY" | tr '[:upper:]' '[:lower:]')  
    while [ "y" != "$NFT_CONNECTED_ALREADY" ] && [ "n" != "$NFT_CONNECTED_ALREADY" ] ; do
    echo
    echo "Not a valid answer (y or n)"
    echo "Is the deployed ERC721 already protocol enabled (connected to a handler) (y or n)?"
    read NFT_CONNECTED_ALREADY
    NFT_CONNECTED_ALREADY=$(echo "$NFT_CONNECTED_ALREADY" | tr '[:upper:]' '[:lower:]')  
    done
    if [ "$NFT_CONNECTED_ALREADY" = "n" ]; then
      forge script script/clientScripts/DeployERC721Handler.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
      forge script script/clientScripts/DeployERC721HandlerPt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    fi
  fi
  echo "Do you want to deploy an ERC721 (y or n)?"
  read ERC721_DEPLOYMENT
  ERC721_DEPLOYMENT=$(echo "$ERC721_DEPLOYMENT" | tr '[:upper:]' '[:lower:]')  
  while [ "y" != "$ERC721_DEPLOYMENT" ] && [ "n" != "$ERC721_DEPLOYMENT" ] ; do
  echo
  echo "Not a valid answer (y or n)"
  echo "Do you want to deploy an ERC721 (y or n)?"
  read ERC721_DEPLOYMENT
  ERC721_DEPLOYMENT=$(echo "$ERC721_DEPLOYMENT" | tr '[:upper:]' '[:lower:]')  
  done
  if [ "$ERC721_DEPLOYMENT" = "y" ]; then
    forge script script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    sh script/ParseApplicationDeploy.sh 3 --chainid $CHAIN_ID 
    forge script script/clientScripts/Application_Deploy_04_ApplicationNFTPt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
  fi
  echo "Do you want to deploy an ERC721 upgradeable (y or n)?"
  read ERC721_UPGRADE_DEPLOYMENT
  ERC721_UPGRADE_DEPLOYMENT=$(echo "$ERC721_UPGRADE_DEPLOYMENT" | tr '[:upper:]' '[:lower:]')  
  while [ "y" != "$ERC721_UPGRADE_DEPLOYMENT" ] && [ "n" != "$ERC721_UPGRADE_DEPLOYMENT" ] ; do
  echo
  echo "Not a valid answer (y or n)"
  echo "Do you want to deploy an ERC721 upgradeable (y or n)?"
  read ERC721_UPGRADE_DEPLOYMENT
  ERC721_UPGRADE_DEPLOYMENT=$(echo "$ERC721_UPGRADE_DEPLOYMENT" | tr '[:upper:]' '[:lower:]')  
  done
  if [ "$ERC721_UPGRADE_DEPLOYMENT" = "y" ]; then
    forge script script/clientScripts/Application_Deploy_04_ApplicationNFTUpgradeable.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    sh script/ParseApplicationDeploy.sh 3 --chainid $CHAIN_ID 
    forge script script/clientScripts/Application_Deploy_04_ApplicationNFTUpgradeablePt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER 
  fi
  echo "Do you want to deploy Oracles (y or n)?"
  read ORACLE_DEPLOYMENT
  ORACLE_DEPLOYMENT=$(echo "$ORACLE_DEPLOYMENT" | tr '[:upper:]' '[:lower:]')  
  while [ "y" != "$ORACLE_DEPLOYMENT" ] && [ "n" != "$ORACLE_DEPLOYMENT" ] ; do
  echo
  echo "Not a valid answer (y or n)"
  echo "Do you want to deploy Oracles (y or n)?"
  read ORACLE_DEPLOYMENT
  ORACLE_DEPLOYMENT=$(echo "$ORACLE_DEPLOYMENT" | tr '[:upper:]' '[:lower:]')  
  done
  if [ "$ORACLE_DEPLOYMENT" = "y" ]; then
    forge script script/clientScripts/Application_Deploy_05_Oracle.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    sh script/ParseApplicationDeploy.sh 4 --chainid $CHAIN_ID
  fi
  echo "Do you want to deploy Pricers (y or n)?"
  read PRICING_DEPLOYMENT
  PRICING_DEPLOYMENT=$(echo "$PRICING_DEPLOYMENT" | tr '[:upper:]' '[:lower:]')  
  while [ "y" != "$PRICING_DEPLOYMENT" ] && [ "n" != "$PRICING_DEPLOYMENT" ] ; do
  echo
  echo "Not a valid answer (y or n)"
  echo "Do you want to deploy Pricers (y or n)?"
  read PRICING_DEPLOYMENT
  PRICING_DEPLOYMENT=$(echo "$PRICING_DEPLOYMENT" | tr '[:upper:]' '[:lower:]')  
  done
  if [ "$PRICING_DEPLOYMENT" = "y" ]; then
    forge script script/clientScripts/Application_Deploy_06_Pricing.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
    sh script/ParseApplicationDeploy.sh 5 --chainid $CHAIN_ID
  fi
  echo "Do you want to Set Admin Roles (y or n)?"
  read SET_ADMINS
  SET_ADMINS=$(echo "$SET_ADMINS" | tr '[:upper:]' '[:lower:]')  
  while [ "y" != "$SET_ADMINS" ] && [ "n" != "$SET_ADMINS" ] ; do
  echo
  echo "Not a valid answer (y or n)"
  echo "Do you want to Set Admin Roles (y or n)?"
  read SET_ADMINS
  SET_ADMINS=$(echo "$SET_ADMINS" | tr '[:upper:]' '[:lower:]')  
  done
  if [ "$SET_ADMINS" = "y" ]; then
    forge script script/clientScripts/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
  fi
else 
  # deploy full application
  forge script script/clientScripts/Application_Deploy_01_AppManager.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL --gas-price $GAS_NUMBER
  sh script/ParseApplicationDeploy.sh 1 --chainid $CHAIN_ID
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