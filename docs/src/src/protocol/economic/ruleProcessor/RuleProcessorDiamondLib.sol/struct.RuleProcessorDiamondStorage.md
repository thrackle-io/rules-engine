# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/8134a3beedf036c43fc49cdc1818732eb057f270/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

