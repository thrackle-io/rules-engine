# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/759037970009f24ec0ac5995bf26019f0b6997be/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

