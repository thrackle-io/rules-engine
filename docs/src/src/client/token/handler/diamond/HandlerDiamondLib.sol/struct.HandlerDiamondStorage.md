# HandlerDiamondStorage
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/00cdc21330585fccf9dc326a2f7aeba02706eb37/src/client/token/handler/diamond/HandlerDiamondLib.sol)


```solidity
struct HandlerDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

