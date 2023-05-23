# TaggedRuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/63b22fe4cc7ce8c74a4c033635926489351a3581/src/economic/ruleProcessor/tagged/TaggedRuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct TaggedRuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

