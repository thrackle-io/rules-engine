# HandlerDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/46cb5e729fbe3c8dc7b7ecacae59ec49544d86f9/src/client/token/handler/diamond/HandlerDiamondLib.sol)


```solidity
struct HandlerDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

