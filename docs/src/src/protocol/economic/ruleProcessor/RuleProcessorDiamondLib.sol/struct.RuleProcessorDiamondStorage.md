# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/63fcd46f6c4c395f84afa43dab91856da44b1c42/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

