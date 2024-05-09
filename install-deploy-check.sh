#!/bin/bash
set +e # Proceed on errors
cd "$(dirname "$0")"

GITHUB_BRANCH_NAME=${GITHUB_BRANCH_NAME:-HEAD}
SNS_TOPIC_ARN="arn:aws:sns:us-east-1:560711875040:GHDeployTest"

SCRIPT_MODE=${1:-0}
# Ensures foundry is installed and up to date with foundry.lock
./foundry-version-check.sh

source ~/.bashrc
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --quiet -r requirements.txt

case $SCRIPT_MODE in
  "--with-build")
    echo "Building..."
    ;;
  "--with-deploy-check")
    echo "Deploying..."
    ;;
  *)
    echo "No script mode specified. Provide --with-build or --with-deploy-check. Exiting..."
    exit 1
    ;;
esac

if [ $SCRIPT_MODE = "--with-build" ]; then
  forge build
fi

if [ $SCRIPT_MODE = "--with-deploy-check" ]; then
  echo "Running Deployments to Anvil... Only errors will be displayed."
  # {
  #   source script/SetupProtocolDeploy.sh
  #   forge script script/DeployAllModulesPt1.s.sol --ffi --broadcast
  #   source script/ParseProtocolDeploy.sh
  #   forge script script/DeployAllModulesPt2.s.sol --ffi --broadcast
  #   forge script script/DeployAllModulesPt3.s.sol --ffi --broadcast
  #   forge script script/DeployAllModulesPt4.s.sol --ffi --broadcast

  #   forge script script/clientScripts/Application_Deploy_01_AppManager.s.sol --ffi --broadcast
  #   source script/ParseApplicationDeploy.sh 1
  #   forge script script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol --ffi --broadcast 
  #   source script/ParseApplicationDeploy.sh 2
  #   forge script script/clientScripts/Application_Deploy_02_ApplicationFT1Pt2.s.sol --ffi --broadcast 
  #   forge script script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol --ffi --broadcast
  #   source script/ParseApplicationDeploy.sh 3
  #   forge script script/clientScripts/Application_Deploy_04_ApplicationNFTPt2.s.sol --ffi --broadcast 
  #   forge script script/clientScripts/Application_Deploy_05_Oracle.s.sol --ffi --broadcast 
  #   source script/ParseApplicationDeploy.sh 4
  #   forge script script/clientScripts/Application_Deploy_06_Pricing.s.sol --ffi --broadcast
  #   source script/ParseApplicationDeploy.sh 5
  #   forge script script/clientScripts/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --broadcast
  # } > /dev/null # silence stdout (error output will be shown)

  test_commands=(
    # "forge test --ffi -vv --match-contract RuleProcessorDiamondTest"
    # "forge test --ffi -vv --match-contract ApplicationDeploymentTest"
    # "bash deployAppERC20Test.sh"
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
fi
