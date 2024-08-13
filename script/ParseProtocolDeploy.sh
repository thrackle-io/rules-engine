#!/bin/bash
set -eo pipefail

ENV_FILE=".env"

GREEN='\033[0;32m'
RESET='\033[0m'

# Fallback to DB_CHAIN or 31337 if neither are set
CHAIN_ID=${CHAIN_ID:-${DB_CHAIN:-31337}}

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

echo -e "$GREEN $RULE_PROCESSOR_DIAMOND"
echo -e $RESET

os=$(uname -a)
if [[ $os == *"Darwin"* ]]; then
  sed -i '' 's/RULE_PROCESSOR_DIAMOND=.*/RULE_PROCESSOR_DIAMOND='$RULE_PROCESSOR_DIAMOND'/g' $ENV_FILE
  sed -i '' 's/DEPLOYMENT_RULE_PROCESSOR_DIAMOND=.*/DEPLOYMENT_RULE_PROCESSOR_DIAMOND='$RULE_PROCESSOR_DIAMOND'/g' $ENV_FILE
else
  sed -i 's/RULE_PROCESSOR_DIAMOND=.*/RULE_PROCESSOR_DIAMOND='$RULE_PROCESSOR_DIAMOND'/g' $ENV_FILE
  sed -i 's/DEPLOYMENT_RULE_PROCESSOR_DIAMOND=.*/DEPLOYMENT_RULE_PROCESSOR_DIAMOND='$RULE_PROCESSOR_DIAMOND'/g' $ENV_FILE
fi
