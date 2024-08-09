#!/bin/bash
export TERM=xterm-color
BLUE="\e[94m"
ENDBLUE="\e[0m"
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
# Helper script for running the slither-check-upgradeability tool

# ****** ERC721 Upgradeable Contracts ******
erc721uContracts=(ProtocolERC721U ProtocolERC721Umin)

for c in "${erc721uContracts[@]}"; do
  printf "${BLUE}***** Contract: $c Proxy: ApplicationERC721UProxy *****${ENDBLUE}\n"
  printf "${BLUE}********* Command: slither-check-upgradeability . "$c" --proxy-name ApplicationERC721UProxy *****${ENDBLUE}\n"
  test=$(slither-check-upgradeability . "$c" --proxy-name ApplicationERC721UProxy 2>&1)
  echo $test 
  TEST_OUTPUT=$(echo $test | grep "INFO:Slither:0")
  if [[ -z "$TEST_OUTPUT" ]]; then
    FAIL=true
    printf "${RED} Fail ${NC}\n"
  else
    printf "${GREEN} Pass ${NC}\n"
  fi
done

# ****** ERC20 Upgradeable Contracts ******
erc20uContracts=(ProtocolERC20UMin)

for c in "${erc20uContracts[@]}"; do
  printf "${BLUE}***** Contract: $c Proxy: ApplicationERC20UProxy *****${ENDBLUE}\n"
  printf "${BLUE}********* Command: slither-check-upgradeability . "$c" --proxy-name ApplicationERC20UProxy *****${ENDBLUE}\n"
  test=$(slither-check-upgradeability . "$c" --proxy-name ApplicationERC20UProxy 2>&1)
  echo $test 
  TEST_OUTPUT=$(echo $test | grep "INFO:Slither:0")
  if [[ -z "$TEST_OUTPUT" ]]; then
    FAIL=true
    printf "${RED} Fail ${NC}\n"
  else
    printf "${GREEN} Pass ${NC}\n"
  fi
done

# ****** Diamond Contracts ******
diamondContracts=(ApplicationAccessLevelProcessorFacet ApplicationPauseProcessorFacet ApplicationRiskProcessorFacet AppRuleDataFacet ERC20RuleProcessorFacet
                  ERC20TaggedRuleProcessorFacet ERC721RuleProcessorFacet ERC721TaggedRuleProcessorFacet RuleApplicationValidationFacet RuleDataFacet TaggedRuleDataFacet)

for c in "${diamondContracts[@]}"; do
  printf "${BLUE}***** Contract: $c Proxy: RuleProcessorDiamond *****${ENDBLUE}\n"
  printf "${BLUE}********* Command: slither-check-upgradeability . "$c" --proxy-name RuleProcessorDiamond *****${ENDBLUE}\n"
  test=$(slither-check-upgradeability . "$c" --proxy-name RuleProcessorDiamond 2>&1)
  echo $test 
  TEST_OUTPUT=$(echo $test | grep "INFO:Slither:0")
  if [[ -z "$TEST_OUTPUT" ]]; then
    FAIL=true
    printf "${RED} Fail ${NC}\n"
  else
    printf "${GREEN} Pass ${NC}\n"
  fi
done
if [ "$FAIL" = true ]; then
  echo "ERROR: Failed to pass all checks. See individual results for details."
  exit -1 # terminate and indicate error
fi