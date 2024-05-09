# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/e7a29d289e813f2ec0afb244343b31481470bf5f/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

