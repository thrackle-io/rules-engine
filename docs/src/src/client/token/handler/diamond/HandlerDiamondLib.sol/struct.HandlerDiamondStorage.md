# HandlerDiamondStorage
[Git Source](https://github.com/thrackle-io/forte-rules-engine/blob/cb826e7b7899f2d90490d1eaeb0e665e017648fa/src/client/token/handler/diamond/HandlerDiamondLib.sol)


```solidity
struct HandlerDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

