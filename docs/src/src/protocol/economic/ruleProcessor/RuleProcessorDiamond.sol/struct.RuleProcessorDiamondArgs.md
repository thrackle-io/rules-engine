# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/845c12315ef4ac1a6cc2b1c3212b2b372da974eb/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

