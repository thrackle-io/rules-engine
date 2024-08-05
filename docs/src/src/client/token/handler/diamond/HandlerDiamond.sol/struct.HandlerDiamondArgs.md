# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/3646d7220ca1c3c6e396c1c58012716f59073c50/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

