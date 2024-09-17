# HandlerDiamondStorage
[Git Source](https://github.com/thrackle-io/rules-engine/blob/0add9b8cd140006448dad92dd54fc23fca23f012/src/client/token/handler/diamond/HandlerDiamondLib.sol)


```solidity
struct HandlerDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

