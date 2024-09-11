# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/rules-engine/blob/8e8136863cc533050498938ef97f694c7b6600c3/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

