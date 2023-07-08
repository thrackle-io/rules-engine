# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/1ab1db06d001c0ea3265ec49b85ddd9394430302/src/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

