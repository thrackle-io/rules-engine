# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/bcd51b65303028319f618c7ac3ded4f0d5f7d964/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

