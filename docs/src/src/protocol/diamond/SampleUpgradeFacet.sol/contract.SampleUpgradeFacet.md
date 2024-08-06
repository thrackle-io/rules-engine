# SampleUpgradeFacet
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/35ec513a185f22e7ba035815b9ced8c0ef1497a9/src/protocol/diamond/SampleUpgradeFacet.sol)

**Inherits:**
ERC173

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


## Functions
### sampleUpgradeFunction


```solidity
function sampleUpgradeFunction() external view onlyOwner returns (string memory);
```

