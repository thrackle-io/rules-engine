# SampleUpgradeFacet
[Git Source](https://github.com/thrackle-io/tron/blob/6347e28a06cfe8dcc416f54eea2d35ee6b0ce9fd/src/protocol/diamond/SampleUpgradeFacet.sol)

**Inherits:**
ERC173

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


## Functions
### sampleUpgradeFunction


```solidity
function sampleUpgradeFunction() external view onlyOwner returns (string memory);
```

