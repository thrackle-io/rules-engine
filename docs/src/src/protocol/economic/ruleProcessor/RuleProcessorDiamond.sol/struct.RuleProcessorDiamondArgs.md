# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/5bfb84a51be01d9a959b76979e9b34e41875da67/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

