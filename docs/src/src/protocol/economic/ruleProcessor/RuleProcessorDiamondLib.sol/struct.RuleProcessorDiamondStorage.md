# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/764000f27aa19925e60dae8d757a097eec620706/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

