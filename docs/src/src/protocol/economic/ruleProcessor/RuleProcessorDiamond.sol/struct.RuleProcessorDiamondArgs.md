# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/95d06c720440790216a49a5a69a0411b6dfc3f0f/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

