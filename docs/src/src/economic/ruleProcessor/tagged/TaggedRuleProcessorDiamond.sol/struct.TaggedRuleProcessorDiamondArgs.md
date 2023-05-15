# TaggedRuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/economic/ruleProcessor/tagged/TaggedRuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct TaggedRuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

