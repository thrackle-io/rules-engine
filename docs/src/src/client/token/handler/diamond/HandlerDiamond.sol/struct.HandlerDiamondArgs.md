# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-engine/blob/6d65728d4e93813016499a87fe04f8385b777100/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

