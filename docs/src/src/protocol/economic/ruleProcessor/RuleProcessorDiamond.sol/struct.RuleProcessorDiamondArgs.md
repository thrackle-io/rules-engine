# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/83f9171b0938eaf7bc30d655175a8e0d5f93feb4/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

