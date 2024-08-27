# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/rules-engine/blob/0775549ba2fe667ec66be14a19fcc8b784774a43/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

