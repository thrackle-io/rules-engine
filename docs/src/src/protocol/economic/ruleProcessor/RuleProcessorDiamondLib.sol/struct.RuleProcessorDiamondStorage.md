# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/9006c7893599df6faee125cfb638dc80c156ce12/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

