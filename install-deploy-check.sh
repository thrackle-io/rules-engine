#!/bin/bash

source ~/.bashrc
foundryup --version nightly-fd87629fbc4ae2e0fa00ccf42b4a9ebe1b521d55
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

git submodule update --init --recursive   

forge script script/DeployAllModulesPt1.s.sol --ffi --broadcast
bash script/ParseProtocolDeploy.sh
forge script script/DeployAllModulesPt2.s.sol --ffi --broadcast
forge script script/DeployAllModulesPt3.s.sol --ffi --broadcast
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
    echo "Running K8s Build And Deploy workflow for $GITHUB_BRANCH_NAME"
    export GH_TOKEN=$(aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:560711875040:secret:GHPAT-y6CS5m --region us-east-1 | jq -r '.SecretString' | jq -r .GHPAT)
    gh workflow run k8s.yml --ref $GITHUB_BRANCH_NAME
else 
    echo "Sending sns message for failure"
    aws sns publish --topic-arn arn:aws:sns:us-east-1:560711875040:GHDeployTest --message "Deploy Test failed for branch $GITHUB_BRANCH_NAME"
fi