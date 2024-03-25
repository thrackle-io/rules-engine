# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/764000f27aa19925e60dae8d757a097eec620706/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

