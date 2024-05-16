# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/a6e068f4bc8dd6e86015430d874759ac1519196d/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

