# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/268b521956cf89a918ed12522e8182d2df0cd3b2/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

