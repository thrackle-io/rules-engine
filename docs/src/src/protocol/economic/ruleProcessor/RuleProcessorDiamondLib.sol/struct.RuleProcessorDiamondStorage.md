# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/d5d71b820b889f2fefe2639a8f5979e5f09110ed/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

