#!/bin/bash

SCRIPT_MODE=$1

source ~/.bashrc
foundryup
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

if [ $SCRIPT_MODE = "--with-deploy-check" ]; then
  forge build
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

  TEST_ONE_UNCUT=$(forge test --ffi -vv --match-contract RuleProcessorDiamondTest)
  TEST_ONE=$(echo $TEST_ONE_UNCUT | tail -n 1 | grep "0m failed" | wc -l | tr -d ' ')
  TEST_TWO_UNCUT=$(forge test --ffi -vv --match-contract ApplicationDeploymentTest)
  TEST_TWO=$(echo $TEST_TWO_UNCUT | tail -n 1 | grep "0m failed" | wc -l | tr -d ' ')
  TEST_THREE_UNCUT=$(bash deployAppERC20Test.sh)
  TEST_THREE=$(echo TEST_THREE_UNCUT | tail -n 1 | grep "FAIL" | wc -l | tr -d ' ')
  TEST_FOUR_UNCUT=$(bash deployAppERC721Test.sh)
  TEST_FOUR=$(echo TEST_FOUR_UNCUT | tail -n 1 | grep "FAIL" | wc -l | tr -d ' ')

  TEST_FIVE_UNCUT=$(node abi-aggregator.mjs --branch $GITHUB_BRANCH_NAME)
  TEST_FIVE=$?

  echo $TEST_ONE_UNCUT
  echo $TEST_TWO_UNCUT
  echo $TEST_THREE_UNCUT
  echo $TEST_FOUR_UNCUT
  echo $TEST_FIVE_UNCUT

  if [ "1" = "$TEST_ONE" ] && [ "1" = "$TEST_TWO" ] && [ "0" == "$TEST_THREE" ] && [ "0" == "$TEST_FOUR" ] && [ "0" == "$TEST_FIVE" ]; then
    echo "Running K8s Build And Deploy workflow for $GITHUB_BRANCH_NAME"
    export GH_TOKEN=$(aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:560711875040:secret:GHPAT-y6CS5m --region us-east-1 | jq -r '.SecretString' | jq -r .GHPAT)
    gh workflow run k8s.yml --ref $GITHUB_BRANCH_NAME
  else 
    echo "Sending sns message for failure"
    aws sns publish --topic-arn arn:aws:sns:us-east-1:560711875040:GHDeployTest --message "Deploy Test failed for branch $GITHUB_BRANCH_NAME"
  fi
fi
