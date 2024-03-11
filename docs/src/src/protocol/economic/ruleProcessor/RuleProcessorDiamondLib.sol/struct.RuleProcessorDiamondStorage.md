# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/13105ed31bc78c8d50cdf97173deb83a68e88dee/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

