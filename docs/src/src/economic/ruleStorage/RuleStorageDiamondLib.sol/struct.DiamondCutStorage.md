# DiamondCutStorage
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/1ab1db06d001c0ea3265ec49b85ddd9394430302/src/economic/ruleStorage/RuleStorageDiamondLib.sol)


```solidity
struct DiamondCutStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

