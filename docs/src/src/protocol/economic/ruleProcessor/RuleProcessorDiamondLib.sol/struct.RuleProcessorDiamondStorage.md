# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/13349942d6b36cb5b881624be044b28167a194cf/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

