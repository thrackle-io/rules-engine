# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-engine/blob/3a9da30daa774fa67b31c000e53f0c753deac1be/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

