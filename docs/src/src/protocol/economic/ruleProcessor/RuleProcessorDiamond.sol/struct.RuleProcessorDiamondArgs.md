# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/22d59d8913fec75ff35111960d6c2b98915a9f8b/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

