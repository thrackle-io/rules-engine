# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/cbc87814d6bed0b3e71e8ab959486c532d05c771/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

