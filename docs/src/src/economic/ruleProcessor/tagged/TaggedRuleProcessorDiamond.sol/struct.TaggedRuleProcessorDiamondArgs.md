# TaggedRuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/economic/ruleProcessor/tagged/TaggedRuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct TaggedRuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

