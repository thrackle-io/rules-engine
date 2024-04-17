# HandlerDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/2c06fb72526db5cd6662cbeec5fef5842b764c6f/src/client/token/handler/diamond/HandlerDiamondLib.sol)


```solidity
struct HandlerDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

