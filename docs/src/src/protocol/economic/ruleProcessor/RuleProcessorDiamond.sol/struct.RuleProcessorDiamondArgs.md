# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/f0b9409d0746d035136fce54b3907220cf162a23/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

