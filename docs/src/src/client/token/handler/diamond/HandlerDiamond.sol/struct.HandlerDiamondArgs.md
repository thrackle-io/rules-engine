# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/8f8cd9f0e8cf797290e5a764c49efd646c572381/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

