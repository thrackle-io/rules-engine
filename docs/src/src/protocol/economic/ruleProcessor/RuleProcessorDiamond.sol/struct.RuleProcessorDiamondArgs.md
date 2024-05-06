# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/4e6a814efa6ccf934f63826b54087808a311218d/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

