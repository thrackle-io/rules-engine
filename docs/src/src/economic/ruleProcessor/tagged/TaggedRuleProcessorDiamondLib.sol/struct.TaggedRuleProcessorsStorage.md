# TaggedRuleProcessorsStorage
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/ca661487b49e5b916c4fa8811d6bdafbe530a6c8/src/economic/ruleProcessor/tagged/TaggedRuleProcessorDiamondLib.sol)


```solidity
struct TaggedRuleProcessorsStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

