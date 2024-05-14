# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/418593f8a1f14afa022635321794b26239d6f80e/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

