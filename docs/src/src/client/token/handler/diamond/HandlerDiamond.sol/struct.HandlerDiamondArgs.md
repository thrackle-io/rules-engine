# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/5d067d497731c6b73733c2217dfac1db063f1640/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

