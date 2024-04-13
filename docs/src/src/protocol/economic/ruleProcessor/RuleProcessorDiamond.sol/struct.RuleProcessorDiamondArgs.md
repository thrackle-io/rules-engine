# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/192018a749cd70c7df311296c3236b79e11af0f3/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

