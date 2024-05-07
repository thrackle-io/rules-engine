# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/845c12315ef4ac1a6cc2b1c3212b2b372da974eb/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

