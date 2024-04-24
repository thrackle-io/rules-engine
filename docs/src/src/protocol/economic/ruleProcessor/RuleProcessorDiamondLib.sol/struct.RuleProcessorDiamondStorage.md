# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/826eee0e9167e4ceebe5bb3df2058b377df8b6bc/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

