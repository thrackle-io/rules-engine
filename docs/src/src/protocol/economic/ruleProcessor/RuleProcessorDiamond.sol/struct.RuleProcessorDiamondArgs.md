# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/81b80009ad5682c206d626e3be15fff689d615e0/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

