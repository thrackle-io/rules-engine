# HandlerDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/35220e3468902ae927d760ed6963ae4507446c20/src/client/token/handler/diamond/HandlerDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct HandlerDiamondArgs {
    address init;
    bytes initCalldata;
}
```

