# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/a0f5ead5c8fc9d4614336dc446184e42c1f4b0fa/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

