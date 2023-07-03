# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/9adfea3f253340fbb4af30cdc0009d491b72e160/src/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

