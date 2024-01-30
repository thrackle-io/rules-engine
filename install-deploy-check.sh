#!/bin/bash

source ~/.bashrc
foundryup
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

git submodule update --init --recursive   

forge script script/DeployAllModules.s.sol --ffi --broadcast
bash script/ParseProtocolDeploy.sh
forge script script/clientScripts/ApplicationDeployAll.s.sol --ffi  --broadcast -vvv --non-interactive
bash script/ParseApplicationDeploy.sh

TEST_ONE_UNCUT=$(forge test --ffi -vv --match-contract RuleProcessorDiamondTest)
TEST_ONE=$(echo $TEST_ONE_UNCUT | tail -n 1 | grep "0m failed" | wc -l | tr -d ' ')
TEST_TWO_UNCUT=$(forge test --ffi -vv --match-contract ApplicationDeploymentTest)
TEST_TWO=$(echo $TEST_TWO_UNCUT | tail -n 1 | grep "0m failed" | wc -l | tr -d ' ')

echo $TEST_ONE_UNCUT
echo $TEST_TWO_UNCUT

echo $TEST_ONE
echo $TEST_TWO

if [ "1" = "$TEST_ONE" ] && [ "1" = "$TEST_TWO" ] ; then
    echo "BRANCH NAME: "
    echo $GITHUB_BRANCH_NAME
    export GH_TOKEN=$(aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:560711875040:secret:GHPAT-y6CS5m --region us-east-1 | jq -r '.SecretString' | jq -r .GHPAT)
    gh workflow run k8s.yml --ref SE-471-Create-Deployment-Tests-and-Actions-for-Tron-and-add-deployment-verification-to-build-scripts
fi