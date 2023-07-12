# DiamondCutStorage
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/2eb992c5f8a67ecb6f7fb3675bc386aaa483c728/src/economic/ruleStorage/RuleStorageDiamondLib.sol)


```solidity
struct DiamondCutStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

