# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/8134a3beedf036c43fc49cdc1818732eb057f270/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

