# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/a0e7b20980bb06404eb010a144cfad3764962831/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

