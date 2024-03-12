# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/d12cfa3cb48422acc5d155aaf1a5d1ffab60585d/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

