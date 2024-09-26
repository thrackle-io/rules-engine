# HandlerDiamondStorage
[Git Source](https://github.com/thrackle-io/rules-engine/blob/9f8d8e88474215a5428a3c0196051d47d58e8650/src/client/token/handler/diamond/HandlerDiamondLib.sol)


```solidity
struct HandlerDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

