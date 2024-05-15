#!/bin/bash
set -e

SCRIPT_MODE=${1:-0}

##
# the --with-deploy-check flag is passed into this script by the main k8s.yml GH workflow,
# so that it can confirm that the build will successfully deploy. Because that happens in GHA
# in that case we override the FOUNDRY_PROFILE setting and start our own anvil service here
# for it to deploy to and confirm success, and then GHA will just delete the whole test image
# and push the tron and anvil builds to ECR. 
##
if [ $SCRIPT_MODE = "--with-deploy-check" ]; then
	FOUNDRY_PROFILE=local
  anvil --host 0.0.0.0 --chain-id 31337 > /dev/null &
  sleep 2
fi

## This script should only ever be run on a `compile-tron` or higher layer of the tron
## Dockerfile, which is where this venv will have been created. If this script is run
## in some other context it will fail on this line due to the missing venv. 
source .venv/bin/activate

{
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
} > /dev/null

if [ $SCRIPT_MODE = "--with-deploy-check" ]; then
  test_commands=(
    "forge test --ffi -vv --match-contract RuleProcessorDiamondTest"
    "forge test --ffi -vv --match-contract ApplicationDeploymentTest"
    "bash deployAppERC20Test.sh"
    "bash deployAppERC721Test.sh"
    "node abi-aggregator.mjs --branch \"$GITHUB_BRANCH_NAME\""
  )

  echo "Running tests..."
  NUM_FAILED=0
  for command in "${test_commands[@]}"; do
      # Run command in a subshell and capture stderr
      output=$( { eval "$command"; } 2>&1 )
      # Capture return value
      retval=$?

      # If return value is non-zero, the test failed
      if [ $retval -ne 0 ]; then
        echo " ❌ '$command' failed. Errors were:\n" >&2
        echo -e "=================================" >&2
        echo -e "$output"
        echo -e "=================================\n" >&2
        NUM_FAILED=$((NUM_FAILED+1))
      fi
  done

  if [ $NUM_FAILED -gt 0 ]; then
    echo "❌ $NUM_FAILED tests failed. Sending SNS message..."
    aws sns publish --topic-arn $SNS_TOPIC_ARN --message "Deploy Test failed for branch $GITHUB_BRANCH_NAME"
    exit 1
  else
    echo "✅ All tests passed."
    echo -e "\n\n!!! TODO in PR 3/3 !!!: GitHub Actions 'Deploy' workflow will run this in a step. This script will no longer invoke a deployment."
  fi
else
  # For a normal deploy, keep the tron container running so that tron devs can exec 
  # into it and run forge tests and other forge/cast/etc commands against a populated 
  # .env file
  tail -f /dev/null
fi