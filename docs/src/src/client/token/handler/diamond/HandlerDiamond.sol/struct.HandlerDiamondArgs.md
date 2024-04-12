# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/898ac13e9c0d669d38da44f8bf60a26e9528ba9b/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

