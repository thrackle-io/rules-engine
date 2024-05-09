# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/90f80c15b8a320b76e44e84890aab8b010252d59/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

