# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/38ad28ed586c360d4509e485bd378da51297351d/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

