# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/1ba87bf9bb403411ce677f8e83126c3bf8cfa713/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

