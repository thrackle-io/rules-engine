# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/121468a758a67e73dd1df571fd4e956242c3c973/src/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

