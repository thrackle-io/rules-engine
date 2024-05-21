# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/3811b4273256819e871165284a320ac92fbb3641/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

