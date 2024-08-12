# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/e484b68f1ca0d10ffe5b3b006faff195ef61dcb9/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

