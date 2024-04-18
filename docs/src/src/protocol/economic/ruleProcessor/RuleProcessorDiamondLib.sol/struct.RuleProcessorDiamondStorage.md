# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/4370cba4c6c86564c45ea5da17298f68b13753b5/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

