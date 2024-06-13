#!/bin/bash
set -e

FOUNDRY_PROFILE=local
anvil --host 0.0.0.0 --chain-id 31337 > /dev/null &
sleep 2

./docker-scripts/deploy-tron.sh > /dev/null

source .venv/bin/activate

test_commands=(
  "forge test --ffi -vv --match-contract RuleProcessorDiamondTest"
  "forge test --ffi -vv --match-contract ApplicationDeploymentTest"
  "bash deployProtocolTest.sh"
  "bash deployAppManagerTest.sh"
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
