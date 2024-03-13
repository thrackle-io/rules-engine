# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/06e770e8df9f2623305edd5cd2be197d5544e702/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

