# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/d3ca0c014d883c12f0128d8139415e7b12c9e982/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

