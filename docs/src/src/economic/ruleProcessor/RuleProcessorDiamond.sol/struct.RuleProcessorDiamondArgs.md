# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/1967bc8c4a91d28c4a17e06555cea67921b90fa3/src/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

