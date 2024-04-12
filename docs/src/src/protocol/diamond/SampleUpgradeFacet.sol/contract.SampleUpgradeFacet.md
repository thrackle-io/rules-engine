# SampleUpgradeFacet
[Git Source](https://github.com/thrackle-io/tron/blob/cbc87814d6bed0b3e71e8ab959486c532d05c771/src/protocol/diamond/SampleUpgradeFacet.sol)

**Inherits:**
ERC173

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


## Functions
### sampleUpgradeFunction


```solidity
function sampleUpgradeFunction() external view onlyOwner returns (string memory);
```

