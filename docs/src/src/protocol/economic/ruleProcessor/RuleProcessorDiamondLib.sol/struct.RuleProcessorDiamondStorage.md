# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/02db7a0f302d98149458dfe5cd5a62ffb6f478a7/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

