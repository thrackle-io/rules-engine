# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/a0e7b20980bb06404eb010a144cfad3764962831/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

