# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/d6cc09e8b231cc94d92dd93b6d49fb2728ede233/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

