# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-engine/blob/15c1cde2fd5aa8a9b7955757546796aaaf1249b9/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

