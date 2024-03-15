# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/d4dc3a1319e6df3195618c1297a6c755d61cf319/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

