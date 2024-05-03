# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/cc8b8345c329b2556fa21578401d762291784e46/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

