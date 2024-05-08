# SampleUpgradeFacet
[Git Source](https://github.com/thrackle-io/tron/blob/0336bb34620bb9e55e13cd371f0aebd8997d21c3/src/protocol/diamond/SampleUpgradeFacet.sol)

**Inherits:**
ERC173

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


## Functions
### sampleUpgradeFunction


```solidity
function sampleUpgradeFunction() external view onlyOwner returns (string memory);
```

