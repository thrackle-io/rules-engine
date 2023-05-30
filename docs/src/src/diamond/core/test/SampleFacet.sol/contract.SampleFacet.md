# SampleFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/49ab19f6a1a98efed1de2dc532ff3da9b445a7cb/src/diamond/core/test/SampleFacet.sol)

**Inherits:**
[ERC173](/src/diamond/implementations/ERC173/ERC173.sol/abstract.ERC173.md)

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


## Functions
### sampleFunction


```solidity
function sampleFunction() external view onlyOwner returns (string memory);
```

