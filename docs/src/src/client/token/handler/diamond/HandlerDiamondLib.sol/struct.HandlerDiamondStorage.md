# HandlerDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/6347e28a06cfe8dcc416f54eea2d35ee6b0ce9fd/src/client/token/handler/diamond/HandlerDiamondLib.sol)


```solidity
struct HandlerDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

