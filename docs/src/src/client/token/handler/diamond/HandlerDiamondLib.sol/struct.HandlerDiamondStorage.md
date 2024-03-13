# HandlerDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/5bfb84a51be01d9a959b76979e9b34e41875da67/src/client/token/handler/diamond/HandlerDiamondLib.sol)


```solidity
struct HandlerDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

