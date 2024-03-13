# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/1a1d6b2809bc510780a53bad6853fa1ef1652aab/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

