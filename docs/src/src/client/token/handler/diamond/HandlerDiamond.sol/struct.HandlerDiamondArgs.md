# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/50727ee9211084f05b8690e3435981873338f44e/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

