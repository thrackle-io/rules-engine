# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/362ca5d8826deeb3c732b79b0826e739dff4e241/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

