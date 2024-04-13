# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/192018a749cd70c7df311296c3236b79e11af0f3/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

