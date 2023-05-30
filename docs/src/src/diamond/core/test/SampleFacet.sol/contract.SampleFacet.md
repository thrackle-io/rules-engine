# SampleFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4f7789968960e18493ff0b85b09856f12969daac/src/diamond/core/test/SampleFacet.sol)

**Inherits:**
[ERC173](/src/diamond/implementations/ERC173/ERC173.sol/abstract.ERC173.md)

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


## Functions
### sampleFunction


```solidity
function sampleFunction() external view onlyOwner returns (string memory);
```

