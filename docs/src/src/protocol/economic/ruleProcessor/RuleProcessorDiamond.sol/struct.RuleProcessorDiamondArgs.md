# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/d0e19eee889b51e6e21299e25b4ddf10ffd75bd7/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

