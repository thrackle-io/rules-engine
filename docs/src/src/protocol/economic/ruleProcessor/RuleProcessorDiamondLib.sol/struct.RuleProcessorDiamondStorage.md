# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/06b5ee57ef76bd8520d1cb281fa59f1af36b76f1/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

