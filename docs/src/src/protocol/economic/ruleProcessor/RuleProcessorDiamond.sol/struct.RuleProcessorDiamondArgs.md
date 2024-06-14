# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/7233064f299d77880af0e175a21e23e2f8b85f56/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

