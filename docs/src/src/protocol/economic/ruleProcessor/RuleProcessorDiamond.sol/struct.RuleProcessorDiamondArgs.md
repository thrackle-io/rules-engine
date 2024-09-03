# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-engine/blob/ea7b4b1d8c8b9c92a6391cd0b67fbb323cf4419d/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

