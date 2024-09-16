# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-engine/blob/54db83a2c72adaf3bc2196e69cb3cf728347d98b/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

