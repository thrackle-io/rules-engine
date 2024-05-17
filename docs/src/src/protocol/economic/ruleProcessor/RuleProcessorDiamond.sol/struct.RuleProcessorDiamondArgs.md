# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/93fd74340f7444498e4353b2c758c1107038174a/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

