# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/29c0f577f4a40a4ed7ae1702ee35ca11ff1ccfaf/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

