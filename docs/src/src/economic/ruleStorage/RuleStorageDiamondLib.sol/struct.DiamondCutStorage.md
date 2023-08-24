# DiamondCutStorage
[Git Source](https://github.com/thrackle-io/tron/blob/fceb75bbcbc9fcccdbb0ae49e82ea903ed8190d1/src/economic/ruleStorage/RuleStorageDiamondLib.sol)


```solidity
struct DiamondCutStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

