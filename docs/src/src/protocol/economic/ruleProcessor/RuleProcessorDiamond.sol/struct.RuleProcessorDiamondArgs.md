# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/17f0c18311739ad27e810cec2eb3f45ea28c2fd7/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

