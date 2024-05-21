# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/3811b4273256819e871165284a320ac92fbb3641/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

