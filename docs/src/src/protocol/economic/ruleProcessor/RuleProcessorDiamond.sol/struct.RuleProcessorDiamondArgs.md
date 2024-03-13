# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/4b8e6b6f1f58764b58a041110acc182dd905d211/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

