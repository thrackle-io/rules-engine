# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/28055da058876a0a8138d3f9a19aa587a0c30e2b/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

