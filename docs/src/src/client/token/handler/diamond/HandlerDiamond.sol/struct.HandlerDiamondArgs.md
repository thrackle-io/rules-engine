# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/bcbcc01a5b28a551282aabeb3b2db849eb2ab94f/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

