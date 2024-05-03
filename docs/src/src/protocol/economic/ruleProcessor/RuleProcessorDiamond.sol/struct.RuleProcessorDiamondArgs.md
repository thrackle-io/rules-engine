# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/cc8b8345c329b2556fa21578401d762291784e46/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

