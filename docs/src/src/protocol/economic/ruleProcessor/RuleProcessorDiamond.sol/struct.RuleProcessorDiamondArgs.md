# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-engine/blob/0add9b8cd140006448dad92dd54fc23fca23f012/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

