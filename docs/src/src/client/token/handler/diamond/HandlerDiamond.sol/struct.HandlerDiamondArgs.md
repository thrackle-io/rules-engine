# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/f0e9b435619e8bdc38f4e9105781dfc663d9f089/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

