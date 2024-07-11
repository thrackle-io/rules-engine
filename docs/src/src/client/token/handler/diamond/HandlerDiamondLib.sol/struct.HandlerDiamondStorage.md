# HandlerDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/29c2cd95da29b0356348370e1ddb4d7bdc24a711/src/client/token/handler/diamond/HandlerDiamondLib.sol)


```solidity
struct HandlerDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

