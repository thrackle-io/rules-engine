# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/de69f371f7fd94a0b22f5a213d7ab3968548d9bf/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

