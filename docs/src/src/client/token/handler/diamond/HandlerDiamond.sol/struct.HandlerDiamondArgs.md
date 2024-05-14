# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/4f1430717249c90fcbde9d9572fe2ac92dc2c5d4/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

