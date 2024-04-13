# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/9665732f3266b703cc028112f97a9a18c551bb91/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

