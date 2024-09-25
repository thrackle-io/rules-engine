# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/rules-engine/blob/6d65728d4e93813016499a87fe04f8385b777100/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

