# TaggedRuleProcessorsStorage
[Git Source](https://github.com/thrackle-io/Tron/blob/8687bd810e678d8633ed877521d2c463c1677949/src/economic/ruleProcessor/nontagged/TaggedRuleProcessorDiamondLib.sol)


```solidity
struct TaggedRuleProcessorsStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

