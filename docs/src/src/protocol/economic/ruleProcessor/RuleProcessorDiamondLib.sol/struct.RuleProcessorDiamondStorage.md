# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/924e2b2b2b0ddb0088202a57363e91b424c36686/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

