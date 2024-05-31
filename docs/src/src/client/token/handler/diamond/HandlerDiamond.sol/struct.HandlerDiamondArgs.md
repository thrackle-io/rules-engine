# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/703713c2070ab34d0f0fc0114244d5a3fa7ac84a/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

