# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/570e509b7dae1b89ffe858956bb3df9bbac2510a/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

