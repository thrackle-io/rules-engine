# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4e5c0bf97c314267dd6acccac5053bfaa6859607/src/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

