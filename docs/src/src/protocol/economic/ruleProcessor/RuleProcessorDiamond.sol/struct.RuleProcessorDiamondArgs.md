# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/263e499d66345014a4fa5059735434da59124980/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

