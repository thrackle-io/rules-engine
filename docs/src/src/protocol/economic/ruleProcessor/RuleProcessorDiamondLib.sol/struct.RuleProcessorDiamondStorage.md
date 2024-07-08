# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/0ca0a263215b0baace3d8d12fd9706eb2a79accf/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

