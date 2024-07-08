# RuleProcessorDiamondArgs
[Git Source](https://github.com/thrackle-io/tron/blob/0ca0a263215b0baace3d8d12fd9706eb2a79accf/src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol)

This is used in diamond constructor
more arguments are added to this struct
this avoids stack too deep errors


```solidity
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}
```

