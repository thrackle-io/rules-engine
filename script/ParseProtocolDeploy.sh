#!/bin/bash

ENV_FILE=".env"

if [[ -n $CHAIN_ID ]]; then
  CHAIN_ID=${CHAIN_ID}
elif [[ -n $DB_CHAIN ]]; then
  CHAIN_ID=${DB_CHAIN}
else
  CHAIN_ID=31337
fi

settingChainID=false

  for var in "$@"
  do
    if [[ "$var" = "--chainid" ]]
    then
      settingChainID=true
    elif $settingChainID;
    then
      CHAIN_ID="$var"
      settingVal=false
    elif [[ "$var" = "--help" ]]
    then
      echo "--------------------------------------------------"
      echo "Possible Arguments:"
      echo "--chainid - set the chain id for the deployment"
      echo "--------------------------------------------------"
      exit
    else
      echo "Unknown Argument"
    fi
  done

# Retreive the Rule Processor Diamond Address
RULE_PROCESSOR_DIAMOND_UNCUT=$(jq '.transactions[] | select(.contractName=="RuleProcessorDiamond") | .contractAddress' broadcast/DeployAllModulesPt1.s.sol/$CHAIN_ID/run-latest.json)

RULE_PROCESSOR_DIAMOND="${RULE_PROCESSOR_DIAMOND_UNCUT//\"}"

echo $RULE_PROCESSOR_DIAMOND
echo 

OWNER=$(sed -n 's/ANVIL_ADDRESS_0=//p' .env)
OWNER_PRIVATE_KEY=$(sed -n 's/ANVIL_PRIVATE_KEY_0=//p' .env) 

APP_ADMIN=$(sed -n 's/ANVIL_ADDRESS_1=//p' .env)
APP_ADMIN_PRIVATE_KEY=$(sed -n 's/ANVIL_PRIVATE_KEY_1=//p' .env) 

os=$(uname -a)
if [[ $os == *"Darwin"* ]]; then
  sed -i '' 's/RULE_PROCESSOR_DIAMOND=.*/RULE_PROCESSOR_DIAMOND='$RULE_PROCESSOR_DIAMOND'/g' $ENV_FILE
  sed -i '' 's/DEPLOYMENT_RULE_PROCESSOR_DIAMOND=.*/DEPLOYMENT_RULE_PROCESSOR_DIAMOND='$RULE_PROCESSOR_DIAMOND'/g' $ENV_FILE
else
  sed -i 's/RULE_PROCESSOR_DIAMOND=.*/RULE_PROCESSOR_DIAMOND='$RULE_PROCESSOR_DIAMOND'/g' $ENV_FILE
  sed -i 's/DEPLOYMENT_RULE_PROCESSOR_DIAMOND=.*/DEPLOYMENT_RULE_PROCESSOR_DIAMOND='$RULE_PROCESSOR_DIAMOND'/g' $ENV_FILE
fi

if [[ $os == *"Darwin"* ]]; then
  sed -i '' 's/^DEPLOYMENT_OWNER=.*/DEPLOYMENT_OWNER='$OWNER'/g' $ENV_FILE
  sed -i '' 's/^DEPLOYMENT_OWNER_KEY=.*/DEPLOYMENT_OWNER_KEY='$OWNER_PRIVATE_KEY'/g' $ENV_FILE
else
  sed -i 's/^DEPLOYMENT_OWNER=.*/DEPLOYMENT_OWNER='$OWNER'/g' $ENV_FILE
  sed -i 's/^DEPLOYMENT_OWNER_KEY=.*/DEPLOYMENT_OWNER_KEY='$OWNER_PRIVATE_KEY'/g' $ENV_FILE
fi

if [[ $os == *"Darwin"* ]]; then
  sed -i '' 's/^APP_ADMIN=.*/APP_ADMIN='$APP_ADMIN'/g' $ENV_FILE
  sed -i '' 's/^APP_ADMIN_PRIVATE_KEY=.*/APP_ADMIN_PRIVATE_KEY='$APP_ADMIN_PRIVATE_KEY'/g' $ENV_FILE
else
  sed -i 's/^APP_ADMIN=.*/APP_ADMIN='$APP_ADMIN'/g' $ENV_FILE
  sed -i 's/^APP_ADMIN_PRIVATE_KEY=.*/APP_ADMIN_PRIVATE_KEY='$APP_ADMIN_PRIVATE_KEY'/g' $ENV_FILE
fi