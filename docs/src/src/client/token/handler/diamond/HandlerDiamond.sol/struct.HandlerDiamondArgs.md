# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/f7f6e3590faaa9c8f0fe0115492201b8f8dd1711/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

