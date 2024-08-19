# HandlerDiamondStorage
[Git Source](https://github.com/thrackle-io/rules-engine/blob/57b349a6cc320a1f7ecb037fec845111fdd03ebb/src/client/token/handler/diamond/HandlerDiamondLib.sol)


```solidity
struct HandlerDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

