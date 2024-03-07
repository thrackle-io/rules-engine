# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/46cb5e729fbe3c8dc7b7ecacae59ec49544d86f9/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

