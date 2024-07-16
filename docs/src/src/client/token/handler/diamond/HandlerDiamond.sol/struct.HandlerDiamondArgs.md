# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/39d269094241d21cf978e159a9b52cf3c140671a/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

