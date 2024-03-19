# SampleUpgradeFacet
[Git Source](https://github.com/thrackle-io/tron/blob/f0b9409d0746d035136fce54b3907220cf162a23/src/protocol/diamond/SampleUpgradeFacet.sol)

**Inherits:**
ERC173

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


## Functions
### sampleUpgradeFunction


```solidity
function sampleUpgradeFunction() external view onlyOwner returns (string memory);
```

