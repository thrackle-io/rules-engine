# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/forte-rules-engine/blob/0c70bcd32f4dcc456508b64e73411cac76dd6f09/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

