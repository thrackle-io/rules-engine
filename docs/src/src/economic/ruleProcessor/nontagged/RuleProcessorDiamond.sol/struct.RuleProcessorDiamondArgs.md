# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/Tron/blob/fff6da56c1f6c87c36b2aaf57f491c1f4da3b2b2/src/economic/ruleProcessor/nontagged/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

