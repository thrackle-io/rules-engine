# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/7030db34eb7187742ede73deed40ef4d7dddaa1b/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

