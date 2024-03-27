# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/67919752074a6ad99319926c762bce79963a8aa4/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

