# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/5f7e8f952b779123753dfeb3491892f00fd8b936/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

