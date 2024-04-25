# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/759037970009f24ec0ac5995bf26019f0b6997be/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

