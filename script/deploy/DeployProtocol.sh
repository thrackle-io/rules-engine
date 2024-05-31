#!/bin/bash
# This script should only be run after the environment variables are set
# correctly according to docs/userGuides/deployment/DEPLOY-PROTOCOL.md
echo "################################################################"
echo Build and deploy Rules Protocol
echo "################################################################"
echo

echo "################################################################"
echo Build Rules Processor Diamond
echo "################################################################"
echo
forge script script/DeployAllModulesPt1.s.sol --ffi --broadcast -vvv --non-interactive --rpc-url=$ETH_RPC_URL --gas-price $GAS_NUMBER

echo "################################################################"
echo Retrieve the Rules Processor Diamond info and set environment variables
echo "################################################################"
echo
bash script/ParseProtocolDeploy.sh --chainid $CHAIN_ID

echo "################################################################"
echo Build, Deploy, and Add Facets Unit 1
echo "################################################################"
echo
forge script script/DeployAllModulesPt2.s.sol --ffi --broadcast -vvv --non-interactive --rpc-url=$ETH_RPC_URL --gas-price $GAS_NUMBER

echo "################################################################"
echo Build, Deploy, and Add Facets Unit 2
echo "################################################################"
echo
forge script script/DeployAllModulesPt3.s.sol --ffi --broadcast -vvv --non-interactive --rpc-url=$ETH_RPC_URL --gas-price $GAS_NUMBER

echo "################################################################"
echo Build, Deploy, and Add Facets Unit 3
echo "################################################################"
echo
forge script script/DeployAllModulesPt4.s.sol --ffi --broadcast -vvv --non-interactive --rpc-url=$ETH_RPC_URL --gas-price $GAS_NUMBER