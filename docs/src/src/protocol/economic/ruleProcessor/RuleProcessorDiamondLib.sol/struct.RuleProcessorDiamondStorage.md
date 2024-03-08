# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/5d067d497731c6b73733c2217dfac1db063f1640/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

