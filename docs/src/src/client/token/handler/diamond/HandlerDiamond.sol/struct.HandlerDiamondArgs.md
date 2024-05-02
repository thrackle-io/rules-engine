# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/502533a6ffb2af342c0e88aaf7562842e91b57b1/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

