# SampleUpgradeFacet
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/5c9d84d4763cc8482f9b9d326982059877bc2610/src/protocol/diamond/SampleUpgradeFacet.sol)

**Inherits:**
ERC173

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


## Functions
### sampleUpgradeFunction


```solidity
function sampleUpgradeFunction() external view onlyOwner returns (string memory);
```

