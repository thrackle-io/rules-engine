# TaggedRuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/Tron/blob/8687bd810e678d8633ed877521d2c463c1677949/src/economic/ruleProcessor/nontagged/TaggedRuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct TaggedRuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

