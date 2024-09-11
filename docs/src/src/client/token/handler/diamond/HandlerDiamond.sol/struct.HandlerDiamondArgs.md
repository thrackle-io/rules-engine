# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-engine/blob/8f688cb5e6148d0b374ef77b936d7812ad0892e1/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

