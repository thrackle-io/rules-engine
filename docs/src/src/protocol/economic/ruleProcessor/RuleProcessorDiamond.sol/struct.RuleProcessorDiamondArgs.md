# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/edf3093a9fed22d64a8edbc89ae73bfbadfe2a42/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

