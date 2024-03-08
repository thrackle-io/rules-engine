# SampleUpgradeFacet
[Git Source](https://github.com/thrackle-io/tron/blob/5d067d497731c6b73733c2217dfac1db063f1640/src/protocol/diamond/SampleUpgradeFacet.sol)

**Inherits:**
ERC173

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


## Functions
### sampleUpgradeFunction


```solidity
function sampleUpgradeFunction() external view onlyOwner returns (string memory);
```

