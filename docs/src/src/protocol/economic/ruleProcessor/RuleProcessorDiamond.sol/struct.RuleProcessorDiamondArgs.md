# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/bbc344dde218df220c4305ef421070eaa38c5cad/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

