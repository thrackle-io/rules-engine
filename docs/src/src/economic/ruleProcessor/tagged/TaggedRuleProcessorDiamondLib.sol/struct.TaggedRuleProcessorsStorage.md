# TaggedRuleProcessorsStorage
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/63b22fe4cc7ce8c74a4c033635926489351a3581/src/economic/ruleProcessor/tagged/TaggedRuleProcessorDiamondLib.sol)


```solidity
struct TaggedRuleProcessorsStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

