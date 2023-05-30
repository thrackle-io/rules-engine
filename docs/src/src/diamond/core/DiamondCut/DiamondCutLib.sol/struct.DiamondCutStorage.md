# DiamondCutStorage
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/941799bce65220406b4d9686c5c5f1ae7c99f4ee/src/diamond/core/DiamondCut/DiamondCutLib.sol)


```solidity
struct DiamondCutStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

