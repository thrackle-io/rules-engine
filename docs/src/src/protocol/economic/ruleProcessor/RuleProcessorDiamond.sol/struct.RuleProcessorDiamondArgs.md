# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/effe36d0b962730eb7c7e200cfcfde3ca3773db8/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

