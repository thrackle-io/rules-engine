# SampleUpgradeFacet
[Git Source](https://github.com/thrackle-io/tron/blob/50727ee9211084f05b8690e3435981873338f44e/src/protocol/diamond/SampleUpgradeFacet.sol)

**Inherits:**
ERC173

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


## Functions
### sampleUpgradeFunction


```solidity
function sampleUpgradeFunction() external view onlyOwner returns (string memory);
```

