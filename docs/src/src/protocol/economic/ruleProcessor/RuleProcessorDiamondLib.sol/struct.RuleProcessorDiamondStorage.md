# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/50727ee9211084f05b8690e3435981873338f44e/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

