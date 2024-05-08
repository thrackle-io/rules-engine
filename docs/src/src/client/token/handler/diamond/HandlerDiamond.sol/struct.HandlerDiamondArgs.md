# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/0336bb34620bb9e55e13cd371f0aebd8997d21c3/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

