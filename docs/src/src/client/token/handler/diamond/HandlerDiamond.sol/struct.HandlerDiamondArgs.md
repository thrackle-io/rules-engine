# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/418593f8a1f14afa022635321794b26239d6f80e/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

