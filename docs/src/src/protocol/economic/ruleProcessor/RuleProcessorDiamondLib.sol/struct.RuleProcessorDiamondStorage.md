# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/fa1f71d854feb4f93c1bbe77dbe731527e9e3d00/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

