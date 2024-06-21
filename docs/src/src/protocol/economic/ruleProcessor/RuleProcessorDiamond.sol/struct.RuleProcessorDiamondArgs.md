# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/e8b36a3b12094b00c1b143dd36d9acbc1f486a67/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

