# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/eb8a3e1cf83581100fd90ef911919e537c2c55cb/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

