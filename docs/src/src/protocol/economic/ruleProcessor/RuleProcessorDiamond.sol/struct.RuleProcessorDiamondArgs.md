# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/47aa0c8585077f5b931483a9b3097e3fe330a3c3/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

