# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/af28404fa455abf3b77fe8e040ff86d48b926353/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

