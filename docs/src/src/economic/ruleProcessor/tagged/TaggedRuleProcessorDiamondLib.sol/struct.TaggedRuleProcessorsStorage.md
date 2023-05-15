# TaggedRuleProcessorsStorage
[Git Source](https://github.com/thrackle-io/Tron/blob/afc52571532b132ea1dea91ad1d1f1af07381e8a/src/economic/ruleProcessor/tagged/TaggedRuleProcessorDiamondLib.sol)


```solidity
struct TaggedRuleProcessorsStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

