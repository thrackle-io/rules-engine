#!/bin/bash
export TERM=xterm-color
BLUE="\e[94m"
ENDBLUE="\e[0m"
# Helper script for running the slither-check-upgradeability tool

# ****** ERC721 Upgradeable Contracts ******
erc721uContracts=(ProtocolERC721U ProtocolERC721Umin)

for c in "${erc721uContracts[@]}"; do
  printf "${BLUE}***** Contract: $c Proxy: ApplicationERC721UProxy *****${ENDBLUE}\n"
  printf "${BLUE}********* Command: slither-check-upgradeability . "$c" --proxy-name ApplicationERC721UProxy *****${ENDBLUE}\n"
  slither-check-upgradeability . "$c" --proxy-name ApplicationERC721UProxy
done

# ****** ERC20 Upgradeable Contracts ******
erc20uContracts=(ProtocolERC20UMin)

for c in "${erc20uContracts[@]}"; do
  printf "${BLUE}***** Contract: $c Proxy: ApplicationERC20UProxy *****${ENDBLUE}\n"
  printf "${BLUE}********* Command: slither-check-upgradeability . "$c" --proxy-name ApplicationERC20UProxy *****${ENDBLUE}\n"
  slither-check-upgradeability . "$c" --proxy-name ApplicationERC20UProxy
done

# ****** Diamond Contracts ******
diamondContracts=(ApplicationAccessLevelProcessorFacet ApplicationPauseProcessorFacet ApplicationRiskProcessorFacet AppRuleDataFacet ERC20RuleProcessorFacet
                  ERC20TaggedRuleProcessorFacet ERC721RuleProcessorFacet ERC721TaggedRuleProcessorFacet RuleApplicationValidationFacet RuleDataFacet TaggedRuleDataFacet)

for c in "${diamondContracts[@]}"; do
  printf "${BLUE}***** Contract: $c Proxy: RuleProcessorDiamond *****${ENDBLUE}\n"
  printf "${BLUE}********* Command: slither-check-upgradeability . "$c" --proxy-name RuleProcessorDiamond *****${ENDBLUE}\n"
  slither-check-upgradeability . "$c" --proxy-name RuleProcessorDiamond
done
