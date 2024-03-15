# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/4674814db01d3b90ed90d394187432e47d662f5c/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

