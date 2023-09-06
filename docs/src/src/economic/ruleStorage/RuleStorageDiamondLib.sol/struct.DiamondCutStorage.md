# DiamondCutStorage
[Git Source](https://github.com/thrackle-io/tron/blob/2e0bd455865a1259ae742cba145517a82fc00f5d/src/economic/ruleStorage/RuleStorageDiamondLib.sol)


```solidity
struct DiamondCutStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

