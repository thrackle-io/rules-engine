#!/bin/bash

echo "Please enter the Chain ID:"
read CHAIN_ID

CORRECT_INPUT=false 
ENV_FILE=".env"

while ! [ "${CORRECT_INPUT}" ] ; do
if [[ "$CHAIN_ID" =~ ^[0-9]{5}$ ]]; then
  CORRECT_INPUT=true
else 
  echo
  echo "Not a valid answer"
  echo "Please enter the Chain ID:"
  read CHAIN_ID 
fi
done

# Retreive the Rule Processor Diamond Address
RULE_PROCESSOR_DIAMOND_UNCUT=$(jq '.transactions[] | select(.contractName=="RuleProcessorDiamond") | .contractAddress' broadcast/DeployAllModules.s.sol/$CHAIN_ID/run-latest.json)

RULE_PROCESSOR_DIAMOND="${RULE_PROCESSOR_DIAMOND_UNCUT//\"}"

echo $RULE_PROCESSOR_DIAMOND
echo 

sed -i '' 's/TEST_DEPLOY_RULE_PROCESSOR_DIAMOND=.*/TEST_DEPLOY_RULE_PROCESSOR_DIAMOND='$RULE_PROCESSOR_DIAMOND'/g' $ENV_FILE