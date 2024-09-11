# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-engine/blob/8e8136863cc533050498938ef97f694c7b6600c3/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

