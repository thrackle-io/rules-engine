# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/162302962dc6acd8eb4a5fadda6be1dbd5a16028/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

