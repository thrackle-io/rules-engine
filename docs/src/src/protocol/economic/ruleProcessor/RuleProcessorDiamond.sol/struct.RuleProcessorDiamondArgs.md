# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/rules-engine/blob/0775549ba2fe667ec66be14a19fcc8b784774a43/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

