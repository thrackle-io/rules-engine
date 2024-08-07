# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/f3f89426d30f93406f5ff447f7284dbf958844b4/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

