# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/5605c9510d83af8a1b2bbbbbe9ac058b9e276ba7/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

