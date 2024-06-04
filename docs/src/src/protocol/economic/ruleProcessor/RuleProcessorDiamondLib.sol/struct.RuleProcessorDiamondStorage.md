# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/effe36d0b962730eb7c7e200cfcfde3ca3773db8/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

