# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/ca86a0ac3b5737f1c6c7b1df4820e4363feb10cd/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

