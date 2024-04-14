# HandlerDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/87ff5b38c590a4edb91556fd9ab3428df36445b8/src/client/token/handler/diamond/HandlerDiamondLib.sol)


```solidity
struct HandlerDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

