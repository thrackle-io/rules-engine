# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/e7ccb5e31cec6bae24fd2e457f70702e05f2d4b6/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

