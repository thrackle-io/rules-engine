#!/bin/bash
# Helper script for running the slither-check-upgradeability tool
# It currently just runs checks on the upgradeable ERC721 contracts
erc721uContracts=(ProtocolERC721U ProtocolERC721Umin)

for c in "${erc721uContracts[@]}"; do
  slither-check-upgradeability . "$c" --proxy-name ApplicationERC721UProxy
done
