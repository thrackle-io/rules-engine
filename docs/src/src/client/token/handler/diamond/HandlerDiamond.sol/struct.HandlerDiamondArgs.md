# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/35ec513a185f22e7ba035815b9ced8c0ef1497a9/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

