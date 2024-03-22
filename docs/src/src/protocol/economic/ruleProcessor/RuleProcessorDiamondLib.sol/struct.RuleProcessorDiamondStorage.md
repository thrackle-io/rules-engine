# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/bcbcc01a5b28a551282aabeb3b2db849eb2ab94f/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

